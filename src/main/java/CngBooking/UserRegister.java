//package CngBooking;
//
//import java.io.IOException;
//import java.sql.Connection;
//import java.sql.PreparedStatement;
//
//import javax.servlet.ServletException;
//import javax.servlet.http.HttpServlet;
//import javax.servlet.http.HttpServletRequest;
//import javax.servlet.http.HttpServletResponse;
//import javax.servlet.http.HttpSession;
//
//import com.DbConnection.DBConnection;
//
///**
// * Servlet implementation class UserRegister
// */
//public class UserRegister extends HttpServlet {
//	private static final long serialVersionUID = 1L;
//       
//    /**
//     * @see HttpServlet#HttpServlet()
//     */
//    public UserRegister() {
//        super();
//        // TODO Auto-generated constructor stub
//    }
//
//	/**
//	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
//	 */
//	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
//		// TODO Auto-generated method stub
////		response.getWriter().append("Served at: ").append(request.getContextPath());
//		response.sendRedirect("Login.jsp");
//	}
//
//	/**
//	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
//	 */
//	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
//		// TODO Auto-generated method stub
//		doGet(request, response);
//		
//		int uid=0;
//		String Uname =  request.getParameter("name");
//		String Uemail = request.getParameter("email");
//		String Umob = request.getParameter("mobile");
//		String Upass = request.getParameter("pwd");
//		String Ucity = request.getParameter("city");		
//		
//		try
//		{
//			Connection con = DBConnection.connect();
//			PreparedStatement ptmt = con.prepareStatement("insert into user values(?,?,?,?,?,?)");
//			ptmt.setInt(1, uid);
//			ptmt.setString(2, Uname);
//			ptmt.setString(3, Uemail);
//			ptmt.setString(4, Umob);
//			ptmt.setString(5, Upass);
//			ptmt.setString(6, Ucity);
//			int i = ptmt.executeUpdate();
//			if(con == null) {
//			    throw new RuntimeException("Database connection failed!");
//			}
//
//			if(i>0)
//			{	
//				 HttpSession newSession = request.getSession();
//			     newSession.setAttribute("UserResitered", "User Registered SuccessFully");
//				response.sendRedirect("Login.jsp");
//			}
//			else
//			{
//				response.sendRedirect("404.html");
//			}
//		}
//		catch(Exception e)
//		{
//			e.printStackTrace();
//		}
//	}
//
//}



package CngBooking;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.DbConnection.DBConnection;

public class UserRegister extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String name = value(request, "name");
        String email = value(request, "email");
        String mobile = value(request, "mobile");
        String password = value(request, "pwd");

        if (name.isEmpty() || email.isEmpty() || mobile.isEmpty() || password.isEmpty()) {
            showError(request, response, "Please fill in all required fields.");
            return;
        }

        try (Connection con = DBConnection.connect()) {
            if (con == null) {
                showError(request, response, "Unable to connect to the database. Please check that MySQL is running and configured.");
                return;
            }

            try (PreparedStatement ps = con.prepareStatement(
                    "INSERT INTO users (full_name, email, phone, password) VALUES (?,?,?,?)")) {
                ps.setString(1, name);
                ps.setString(2, email);
                ps.setString(3, mobile);
                ps.setString(4, password);

                int rowsInserted = ps.executeUpdate();
                if (rowsInserted == 0) {
                    showError(request, response, "Your account was not created. Please try again.");
                    return;
                }
            }

            HttpSession session = request.getSession();
            session.setAttribute("UserResitered", "User Registered Successfully");
            response.sendRedirect("Login.jsp");
        } catch (SQLException e) {
            e.printStackTrace();
            if ("23000".equals(e.getSQLState())) {
                showError(request, response, "An account with this email or phone number already exists.");
                return;
            }
            showError(request, response, "Account creation failed. Please check the database setup and try again.");
        }
    }

    private static String value(HttpServletRequest request, String parameter) {
        String value = request.getParameter(parameter);
        return value == null ? "" : value.trim();
    }

    private static void showError(HttpServletRequest request, HttpServletResponse response, String message)
            throws ServletException, IOException {
        request.setAttribute("SignupError", message);
        request.getRequestDispatcher("signup.jsp").forward(request, response);
    }
}
