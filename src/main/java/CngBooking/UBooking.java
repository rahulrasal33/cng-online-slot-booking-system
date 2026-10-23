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

public class UBooking extends HttpServlet {
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
        String station = request.getParameter("station");
        String bookingDate = request.getParameter("date");
        String slotTime = request.getParameter("slot");
        String vehicleType = request.getParameter("vehicleType");
        String vehicleNumber = request.getParameter("vehicleNumber");
        String fullName = request.getParameter("fullName");
        String phone = request.getParameter("phone");
        String email = request.getParameter("email");
        
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
                session.setAttribute("BookingError", "❌ Database connection failed. Please try again.");
                response.sendRedirect("SlotBookings.jsp");
                return;
            }

            // Set transaction isolation level to SERIALIZABLE for maximum concurrency control
            int originalIsolation = con.getTransactionIsolation();
            con.setTransactionIsolation(Connection.TRANSACTION_SERIALIZABLE);
            
            // Set auto-commit to false for transaction management
            con.setAutoCommit(false);
            
            try {
                // CRITICAL: Use SELECT FOR UPDATE to lock rows and prevent race conditions
                // This ensures that only one transaction can check and book a slot at a time
                String checkSql = "SELECT booking_id FROM slot_bookings " +
                                "WHERE pump_id = ? AND booking_date = ? AND slot_time = ? " +
                                "AND status != 'CANCELLED' " +
                                "FOR UPDATE"; // Locks matching rows until transaction commits/rolls back
                
                PreparedStatement checkPst = con.prepareStatement(checkSql);
                checkPst.setInt(1, Integer.parseInt(station));
                checkPst.setDate(2, Date.valueOf(bookingDate));
                checkPst.setString(3, slotTime.trim());
                
                ResultSet checkRs = checkPst.executeQuery();
                boolean slotAlreadyBooked = checkRs.next(); // Returns true if slot exists
                checkRs.close();
                checkPst.close();
                
                if (slotAlreadyBooked) {
                    // Slot is already booked - rollback transaction and release lock
                    con.rollback();
                    con.setAutoCommit(true);
                    con.setTransactionIsolation(originalIsolation);
                    session.setAttribute("BookingError", 
                        "❌ This time slot is already booked by another user. Please select a different time slot.");
                    response.sendRedirect("SlotBookings.jsp");
                    return;
                }
                
                // Slot is available - proceed with booking (lock is still held)
                // Using INSERT with subquery check as additional safety measure
                String sql = "INSERT INTO slot_bookings " +
                        "(pump_id, booking_date, slot_time, user_id, status, " +
                        "vehicle_type, vehicle_number, full_name, phone, email) " +
                        "SELECT ?, ?, ?, ?, 'CONFIRMED', ?, ?, ?, ?, ? " +
                        "WHERE NOT EXISTS (" +
                        "    SELECT 1 FROM slot_bookings " +
                        "    WHERE pump_id = ? AND booking_date = ? AND slot_time = ? " +
                        "    AND status != 'CANCELLED'" +
                        ")";

                PreparedStatement pst = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
                int paramIndex = 1;
                pst.setInt(paramIndex++, Integer.parseInt(station));
                pst.setDate(paramIndex++, Date.valueOf(bookingDate));
                pst.setString(paramIndex++, slotTime.trim());
                pst.setInt(paramIndex++, userId);
                pst.setString(paramIndex++, vehicleType != null ? vehicleType.trim() : "");
                pst.setString(paramIndex++, vehicleNumber != null ? vehicleNumber.trim() : "");
                pst.setString(paramIndex++, fullName != null ? fullName.trim() : "");
                pst.setString(paramIndex++, phone != null ? phone.trim() : "");
                pst.setString(paramIndex++, email != null ? email.trim() : "");
                // Parameters for WHERE NOT EXISTS clause
                pst.setInt(paramIndex++, Integer.parseInt(station));
                pst.setDate(paramIndex++, Date.valueOf(bookingDate));
                pst.setString(paramIndex++, slotTime.trim());

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
                
                if (rowsAffected > 0) {
                    if (bookingId <= 0) {
                        throw new SQLException("The booking was created without a receipt ID.");
                    }
                    // Commit the transaction (releases the lock)
                    con.commit();
                    con.setAutoCommit(true);
                    con.setTransactionIsolation(originalIsolation);
                    response.sendRedirect("DownloadReceipt?bookingId=" + bookingId);
                } else {
                    // No rows affected means slot was booked between check and insert
                    // Rollback transaction
                    con.rollback();
                    con.setAutoCommit(true);
                    con.setTransactionIsolation(originalIsolation);
                    session.setAttribute("BookingError", 
                        "❌ This time slot was just booked by another user. Please select a different time slot.");
                    response.sendRedirect("SlotBookings.jsp");
                }
            } catch (Exception e) {
                // Rollback on any error and restore isolation level
                try {
                    con.rollback();
                    con.setAutoCommit(true);
                    con.setTransactionIsolation(originalIsolation);
                } catch (Exception rollbackEx) {
                    rollbackEx.printStackTrace();
                }
                throw e; // Re-throw to be handled by outer catch block
            }

        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("BookingError", "❌ Booking failed: " + e.getMessage() + ". Please try again.");
            response.sendRedirect("SlotBookings.jsp");
        } finally {
            try {
                if (con != null) con.close();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }
}
