package CngBooking;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.DbConnection.DBConnection;

public class Approve extends HttpServlet {
    private static final long serialVersionUID = 1L;

    public Approve() {
        super();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doPost(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // FIX: AdminDash.jsp's Approve/Delete forms submit "pumpId" and "action",
        // but this servlet was reading "id" - which is always null, so it bounced
        // straight to the error redirect and the seller's status never changed.
        String idParam = request.getParameter("pumpId");
        String action  = request.getParameter("action"); // "APPROVED" or "DELETE"

        if (idParam == null || idParam.isEmpty()) {
            response.sendRedirect("AdminDash.jsp?error=Invalid pump ID");
            return;
        }

        Connection con = null;
        try {
            int id = Integer.parseInt(idParam);
            con = DBConnection.connect();

            if (con == null) {
                response.sendRedirect("AdminDash.jsp?error=Database connection failed");
                return;
            }

            // FIX: registration/login/dashboard all use the "cng_pumps" table with
            // "pump_id" - this servlet was updating a different, unrelated table
            // ("cng_pump" / "cng_id"), so approving a seller here never actually
            // changed the row that CngPumpLogin checks. That's why login kept
            // bouncing back to Login.jsp with "pending admin approval".
            int rs;
            if ("DELETE".equals(action)) {
                PreparedStatement ptmt = con.prepareStatement("DELETE FROM cng_pumps WHERE pump_id = ?");
                ptmt.setInt(1, id);
                rs = ptmt.executeUpdate();
                ptmt.close();
            } else {
                PreparedStatement ptmt = con.prepareStatement("UPDATE cng_pumps SET status = ? WHERE pump_id = ?");
                ptmt.setString(1, "APPROVED");
                ptmt.setInt(2, id);
                rs = ptmt.executeUpdate();
                ptmt.close();
            }

            if (rs > 0) {
                response.sendRedirect("AdminDash.jsp?success=Updated successfully");
            } else {
                response.sendRedirect("AdminDash.jsp?error=Pump not found");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("AdminDash.jsp?error=Error: " + e.getMessage());
        } finally {
            try { if (con != null) con.close(); } catch (Exception ignored) {}
        }
    }
}

