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

public class ReleaseHoldServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

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

            SlotHoldTable.ensureExists(con);
            
            PreparedStatement pst = con.prepareStatement(
                    "DELETE FROM " + SlotHoldTable.TABLE + " " +
                            "WHERE pump_id = ? AND booking_date = ? AND slot_time = ? " +
                            "AND user_id = ? AND session_id = ?"
            );
            pst.setInt(1, Integer.parseInt(stationId));
            pst.setDate(2, Date.valueOf(bookingDate));
            pst.setString(3, slotTime.trim());
            pst.setInt(4, userId);
            pst.setString(5, sessionId);
            int deleted = pst.executeUpdate();
            pst.close();

            out.print(new JSONObject().put("status", "released").put("deleted", deleted).toString());
        } catch (Exception e) {
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

