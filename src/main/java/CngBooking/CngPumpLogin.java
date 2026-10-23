package CngBooking;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import com.DbConnection.DBConnection;

public class CngPumpLogin extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // The login field accepts email OR mobile number
        String loginId = request.getParameter("email");
        String pass    = request.getParameter("pwd");

        Connection con = null;
        try {
            con = DBConnection.connect();
            if (con == null) {
                request.getSession().setAttribute("UserLoginError", "Database connection failed");
                response.sendRedirect("Login.jsp");
                return;
            }

            // Try login by email OR mobileNo, must be APPROVED
            PreparedStatement pst = con.prepareStatement(
                "SELECT * FROM cng_pumps WHERE (email = ? OR mobileNo = ?) " +
                "AND password = ? AND status = 'APPROVED'"
            );
            pst.setString(1, loginId);
            pst.setString(2, loginId);
            pst.setString(3, pass);

            ResultSet rs = pst.executeQuery();

            if (rs.next()) {
                HttpSession session = request.getSession();
                session.setAttribute("pumpId",    rs.getInt("pump_id"));
                session.setAttribute("pumpName",  rs.getString("pump_name"));
                session.setAttribute("mobile",    rs.getString("mobileNo"));
                session.setAttribute("city",      rs.getString("city"));
                session.setAttribute("address",   rs.getString("address"));
                session.setAttribute("district",  rs.getString("district"));
                session.setAttribute("state",     rs.getString("state"));
                session.setAttribute("role",      "SELLER");
                session.setAttribute("loggedIn",  true);
                rs.close(); pst.close();
                response.sendRedirect("PumpOrders");
            } else {
                rs.close(); pst.close();
                // Check if exists but pending/rejected
                PreparedStatement chk = con.prepareStatement(
                    "SELECT status FROM cng_pumps WHERE email = ? OR mobileNo = ?"
                );
                chk.setString(1, loginId);
                chk.setString(2, loginId);
                ResultSet chkRs = chk.executeQuery();
                String msg;
                if (chkRs.next()) {
                    String st = chkRs.getString("status");
                    if ("PENDING".equals(st))
                        msg = "Your registration is pending admin approval.";
                    else if ("REJECTED".equals(st))
                        msg = "Your registration was rejected. Contact admin.";
                    else
                        msg = "Invalid credentials.";
                } else {
                    msg = "No account found. Please register first.";
                }
                chkRs.close(); chk.close();
                request.getSession().setAttribute("UserLoginError", msg);
                response.sendRedirect("Login.jsp");
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("UserLoginError", "Server error: " + e.getMessage());
            response.sendRedirect("Login.jsp");
        } finally {
            try { if (con != null) con.close(); } catch (Exception ignored) {}
        }
    }
}
