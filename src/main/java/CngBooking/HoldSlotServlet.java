package CngBooking;

import com.DbConnection.DBConnection;
import org.json.JSONObject;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class HoldSlotServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final int HOLD_MINUTES = 5;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            out.print(new JSONObject().put("error", "Not logged in").toString());
            return;
        }

        String stationId = request.getParameter("stationId");
        String bookingDate = request.getParameter("date");
        String slotTime = request.getParameter("slot");

        if (stationId == null || bookingDate == null || slotTime == null ||
                stationId.isEmpty() || bookingDate.isEmpty() || slotTime.isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print(new JSONObject().put("error", "Missing parameters").toString());
            return;
        }

        int userId = (int) session.getAttribute("userId");
        String sessionId = session.getId();

        Connection con = null;
        try {
            con = DBConnection.connect();
            if (con == null) {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                out.print(new JSONObject().put("error", "Database connection failed").toString());
                return;
            }

            con.setAutoCommit(false);
            SlotHoldTable.ensureExists(con);

            // If already booked, never allow holding.
            PreparedStatement bookedPst = con.prepareStatement(
                    "SELECT 1 FROM slot_bookings " +
                            "WHERE pump_id = ? AND booking_date = ? AND slot_time = ? AND status != 'CANCELLED' " +
                            "LIMIT 1"
            );
            bookedPst.setInt(1, Integer.parseInt(stationId));
            bookedPst.setDate(2, Date.valueOf(bookingDate));
            bookedPst.setString(3, slotTime.trim());
            ResultSet bookedRs = bookedPst.executeQuery();
            boolean alreadyBooked = bookedRs.next();
            bookedRs.close();
            bookedPst.close();

            if (alreadyBooked) {
                con.rollback();
                response.setStatus(HttpServletResponse.SC_CONFLICT);
                out.print(new JSONObject().put("error", "Slot already booked").toString());
                return;
            }

            // Lock the hold row (if any).
            PreparedStatement holdSelect = con.prepareStatement(
                    "SELECT user_id, session_id, expires_at > NOW() AS active " +
                            "FROM " + SlotHoldTable.TABLE + " " +
                            "WHERE pump_id = ? AND booking_date = ? AND slot_time = ? " +
                            "FOR UPDATE"
            );
            holdSelect.setInt(1, Integer.parseInt(stationId));
            holdSelect.setDate(2, Date.valueOf(bookingDate));
            holdSelect.setString(3, slotTime.trim());
            ResultSet holdRs = holdSelect.executeQuery();

            if (holdRs.next()) {
                int existingUserId = holdRs.getInt("user_id");
                String existingSessionId = holdRs.getString("session_id");
                boolean active = holdRs.getBoolean("active");
                holdRs.close();
                holdSelect.close();

                if (active && !(existingUserId == userId && sessionId.equals(existingSessionId))) {
                    con.rollback();
                    response.setStatus(HttpServletResponse.SC_CONFLICT);
                    out.print(new JSONObject().put("error", "Slot temporarily reserved by another user").toString());
                    return;
                }

                PreparedStatement update = con.prepareStatement(
                        "UPDATE " + SlotHoldTable.TABLE + " " +
                                "SET user_id = ?, session_id = ?, expires_at = DATE_ADD(NOW(), INTERVAL ? MINUTE) " +
                                "WHERE pump_id = ? AND booking_date = ? AND slot_time = ?"
                );
                update.setInt(1, userId);
                update.setString(2, sessionId);
                update.setInt(3, HOLD_MINUTES);
                update.setInt(4, Integer.parseInt(stationId));
                update.setDate(5, Date.valueOf(bookingDate));
                update.setString(6, slotTime.trim());
                update.executeUpdate();
                update.close();
            } else {
                holdRs.close();
                holdSelect.close();

                PreparedStatement insert = con.prepareStatement(
                        "INSERT INTO " + SlotHoldTable.TABLE + " " +
                                "(pump_id, booking_date, slot_time, user_id, session_id, expires_at) " +
                                "VALUES (?, ?, ?, ?, ?, DATE_ADD(NOW(), INTERVAL ? MINUTE))"
                );
                insert.setInt(1, Integer.parseInt(stationId));
                insert.setDate(2, Date.valueOf(bookingDate));
                insert.setString(3, slotTime.trim());
                insert.setInt(4, userId);
                insert.setString(5, sessionId);
                insert.setInt(6, HOLD_MINUTES);
                insert.executeUpdate();
                insert.close();
            }

            con.commit();
            out.print(new JSONObject()
                    .put("status", "held")
                    .put("holdMinutes", HOLD_MINUTES)
                    .toString());

        } catch (Exception e) {
            try {
                if (con != null) con.rollback();
            } catch (Exception ignored) {}
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print(new JSONObject().put("error", e.getMessage() != null ? e.getMessage() : "Unknown error").toString());
        } finally {
            try {
                if (con != null) con.close();
            } catch (Exception ignored) {}
        }
    }
}

