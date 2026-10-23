package CngBooking;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.DbConnection.DBConnection;
import org.json.JSONArray;

public class BookedSlotsServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        
        String stationId = request.getParameter("stationId");
        String bookingDate = request.getParameter("date");
        
        if (stationId == null || bookingDate == null || stationId.isEmpty() || bookingDate.isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"error\":\"Missing parameters: stationId and date are required\"}");
            return;
        }
        
        Connection con = null;
        try {
            con = DBConnection.connect();
            if (con == null) {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                out.print("{\"error\":\"Database connection failed\"}");
                return;
            }

            // Include temporary holds as "booked" and auto-expire old holds.
            SlotHoldTable.ensureExists(con);
            SlotHoldTable.deleteExpired(con);
            
            HttpSession session = request.getSession(false);
            Integer userId = (session != null && session.getAttribute("userId") != null)
                    ? (Integer) session.getAttribute("userId")
                    : null;
            String sessionId = (session != null) ? session.getId() : null;

            // Query to get all booked slots + active holds for the given station and date.
            // Holds owned by the current session are excluded so the user can still select their own held slot.
            boolean excludeOwnHold = (userId != null && sessionId != null);
            String query =
                    "SELECT slot_time FROM slot_bookings " +
                            "WHERE pump_id = ? AND booking_date = ? AND status != 'CANCELLED' " +
                            "UNION " +
                            "SELECT slot_time FROM " + SlotHoldTable.TABLE + " " +
                            "WHERE pump_id = ? AND booking_date = ? AND expires_at > NOW() " +
                            (excludeOwnHold ? "AND NOT (user_id = ? AND session_id = ?)" : "");
            
            PreparedStatement pst = con.prepareStatement(query);
            int idx = 1;
            pst.setInt(idx++, Integer.parseInt(stationId));
            pst.setString(idx++, bookingDate);
            pst.setInt(idx++, Integer.parseInt(stationId));
            pst.setString(idx++, bookingDate);
            if (excludeOwnHold) {
                pst.setInt(idx++, userId);
                pst.setString(idx, sessionId);
            }
            
            ResultSet rs = pst.executeQuery();
            JSONArray bookedSlots = new JSONArray();
            
            while (rs.next()) {
                bookedSlots.put(rs.getString("slot_time"));
            }
            
            rs.close();
            pst.close();
            
            out.print(bookedSlots.toString());
            
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"error\":\"" + e.getMessage() + "\"}");
        } finally {
            try {
                if (con != null) con.close();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }
}
