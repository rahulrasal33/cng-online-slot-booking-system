package CngBooking;

import java.io.IOException;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.DbConnection.DBConnection;

public class UserBooking extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("Login.jsp");
            return;
        }

        int userId = (int) session.getAttribute("userId");

        // Get form data
        String station       = request.getParameter("station");
        String bookingDate   = request.getParameter("date");
        String slotTime      = request.getParameter("slot");
        String vehicleType   = request.getParameter("vehicleType");
        String vehicleNumber = request.getParameter("vehicleNumber");
        String fullName      = request.getParameter("fullName");
        String phone         = request.getParameter("phone");
        String email         = request.getParameter("email");

        System.out.println("====Booking Data Received====");
        System.out.println("station=" + station);
        System.out.println("date=" + bookingDate);
        System.out.println("slot=" + slotTime);
        System.out.println("vehicleType=" + vehicleType);
        System.out.println("vehicleNumber=" + vehicleNumber);
        System.out.println("fullName=" + fullName);
        System.out.println("phone=" + phone);
        System.out.println("email=" + email);
        System.out.println("userId=" + userId);

        // Validation
        if (station == null || bookingDate == null || slotTime == null ||
            vehicleType == null || vehicleNumber == null ||
            fullName == null || phone == null || email == null ||
            station.isEmpty() || bookingDate.isEmpty() || slotTime.isEmpty()) {

            session.setAttribute("BookingError", "Please fill all booking details");
            response.sendRedirect("SlotBookings.jsp");
            return;
        }

        Connection con = null;
        try {
            con = DBConnection.connect();
            if (con == null) {
                session.setAttribute("BookingError", "Database connection failed. Please try again.");
                response.sendRedirect("SlotBookings.jsp");
                return;
            }

            con.setAutoCommit(false);

            // STEP 1: Check if slot is already booked (with row lock)
            System.out.println("====Checking Slot Availability====");
            String checkSql =
                "SELECT booking_id FROM slot_bookings " +
                "WHERE pump_id = ? AND booking_date = ? AND slot_time = ? " +
                "AND status != 'CANCELLED' " +
                "FOR UPDATE";

            PreparedStatement checkPst = con.prepareStatement(checkSql);
            checkPst.setInt(1, Integer.parseInt(station));
            checkPst.setDate(2, Date.valueOf(bookingDate));
            checkPst.setString(3, slotTime.trim());

            ResultSet checkRs = checkPst.executeQuery();
            boolean slotAlreadyBooked = checkRs.next();
            checkRs.close();
            checkPst.close();

            System.out.println("Slot already booked: " + slotAlreadyBooked);

            if (slotAlreadyBooked) {
                con.rollback();
                session.setAttribute("BookingError",
                    "This time slot is already booked by another user. Please select a different time slot.");
                response.sendRedirect("SlotBookings.jsp");
                return;
            }

            // STEP 2: Insert booking (safe double-check with NOT EXISTS)
            System.out.println("====Inserting Booking====");
            String sql =
                "INSERT INTO slot_bookings " +
                "(pump_id, booking_date, slot_time, user_id, status, " +
                "vehicle_type, vehicle_number, full_name, phone, email) " +
                "SELECT ?, ?, ?, ?, 'CONFIRMED', ?, ?, ?, ?, ? " +
                "WHERE NOT EXISTS (" +
                "  SELECT 1 FROM slot_bookings " +
                "  WHERE pump_id = ? AND booking_date = ? AND slot_time = ? " +
                "  AND status != 'CANCELLED'" +
                ")";

            PreparedStatement pst = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            int p = 1;
            pst.setInt(p++, Integer.parseInt(station));
            pst.setDate(p++, Date.valueOf(bookingDate));
            pst.setString(p++, slotTime.trim());
            pst.setInt(p++, userId);
            pst.setString(p++, vehicleType.trim());
            pst.setString(p++, vehicleNumber.trim());
            pst.setString(p++, fullName.trim());
            pst.setString(p++, phone.trim());
            pst.setString(p++, email.trim());
            // NOT EXISTS params
            pst.setInt(p++, Integer.parseInt(station));
            pst.setDate(p++, Date.valueOf(bookingDate));
            pst.setString(p++, slotTime.trim());

            int rowsAffected = pst.executeUpdate();
            int bookingId = 0;
            if (rowsAffected > 0) {
                try (ResultSet generatedKeys = pst.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        bookingId = generatedKeys.getInt(1);
                    }
                }
            }
            pst.close();

            System.out.println("Rows affected: " + rowsAffected);

            if (rowsAffected > 0) {
                if (bookingId <= 0) {
                    throw new SQLException("The booking was created without a receipt ID.");
                }
                // Clean up any hold for this slot (best-effort)
                try {
                    PreparedStatement delHold = con.prepareStatement(
                        "DELETE FROM slot_holds WHERE pump_id = ? AND booking_date = ? AND slot_time = ?"
                    );
                    delHold.setInt(1, Integer.parseInt(station));
                    delHold.setDate(2, Date.valueOf(bookingDate));
                    delHold.setString(3, slotTime.trim());
                    delHold.executeUpdate();
                    delHold.close();
                } catch (Exception ignored) {}

                con.commit();
                System.out.println("Booking saved successfully!");
                response.sendRedirect("DownloadReceipt?bookingId=" + bookingId);
            } else {
                con.rollback();
                System.out.println("No rows inserted - slot was booked by another user between check and insert");
                session.setAttribute("BookingError",
                    "This time slot was just taken by someone else. Please select a different slot.");
                response.sendRedirect("SlotBookings.jsp");
            }

        } catch (NumberFormatException e) {
            e.printStackTrace();
            session.setAttribute("BookingError", "Invalid station ID: " + e.getMessage());
            response.sendRedirect("SlotBookings.jsp");
        } catch (IllegalArgumentException e) {
            e.printStackTrace();
            session.setAttribute("BookingError", "Invalid date format. Expected YYYY-MM-DD, received: " + bookingDate);
            response.sendRedirect("SlotBookings.jsp");
        } catch (java.sql.SQLException e) {
            e.printStackTrace();
            System.out.println("SQLException: " + e.getMessage());
            try { if (con != null) con.rollback(); } catch (Exception ignored) {}
            session.setAttribute("BookingError", "Database error: " + e.getMessage());
            response.sendRedirect("SlotBookings.jsp");
        } catch (Exception e) {
            e.printStackTrace();
            try { if (con != null) con.rollback(); } catch (Exception ignored) {}
            session.setAttribute("BookingError", "Unexpected error: " + e.getMessage());
            response.sendRedirect("SlotBookings.jsp");
        } finally {
            try {
                if (con != null) {
                    con.setAutoCommit(true);
                    con.close();
                }
            } catch (Exception ignored) {}
        }
    }
}
