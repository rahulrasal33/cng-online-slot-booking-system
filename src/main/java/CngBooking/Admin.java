//package CngBooking;
//
//import java.io.IOException;
//import java.sql.Connection;
//import java.sql.PreparedStatement;
//import java.sql.ResultSet;
//
//import javax.servlet.ServletException;
//import javax.servlet.http.Cookie;
//import javax.servlet.http.HttpServlet;
//import javax.servlet.http.HttpServletRequest;
//import javax.servlet.http.HttpServletResponse;
//import javax.servlet.http.HttpSession;
//
//import com.DbConnection.DBConnection;
//import com.DbConnection.GetSet;
//
///**
// * Servlet implementation class Admin
// */
//public class Admin extends HttpServlet {
//	private static final long serialVersionUID = 1L;
//       
//    /**
//     * @see HttpServlet#HttpServlet()
//     */
//    public Admin() {
//        super();
//    }
//
//	/**
//	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
//	 */
//	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
//		response.getWriter().append("Served at: ").append(request.getContextPath());
//	}
//
//	/**
//	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
//	 */
//	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
//		doGet(request, response);
//		
//		String uemail = request.getParameter("email");
//		String upass = request.getParameter("pwd");
//		
//		try
//		{
//			Connection con = DBConnection.connect();
//			PreparedStatement ptmt = con.prepareStatement("select * from admin where email=? and password=?");
//			ptmt.setString(1, uemail);
//			ptmt.setString(2, upass);
//			ResultSet rs= ptmt.executeQuery();
//			if(rs.next())
//			{
//				 int AdminId = rs.getInt("id"); 
//	               
//	 
//	                // Create session
//	                HttpSession session = request.getSession();
//	                session.setAttribute("userId", AdminId); 
//	                session.setAttribute("email", uemail);
//	                session.setAttribute("memberSince", "Jan 2024"); // example, replace with DB value if available
//
//	                // Generate JWT token
//	                String token = JWTUtils.generateToken(uemail ,"ADMIN");
//
//	                // Store JWT in cookie
//	                Cookie jwtCookie = new Cookie("jwtToken", token);
//	                jwtCookie.setHttpOnly(true);  // JS can't access
//	                jwtCookie.setPath("/");       // available across app
//	                response.addCookie(jwtCookie);
//	                HttpSession newSession = request.getSession();
//				    newSession.setAttribute("AdminLoggedIn", "Admin LoggedIn SuccessFully");
//	                // ✅ Redirect to home page
//	                response.sendRedirect("AdminDash.jsp");
//			}
//			else
//			{	
//				 HttpSession newSession = request.getSession();
//				 newSession.setAttribute("UserLoginError", "Invalid email or password");
//		         response.sendRedirect("Login.jsp");
//			
//			}
//			
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
import java.sql.ResultSet;

import javax.servlet.ServletException;
import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.DbConnection.DBConnection;

public class Admin extends HttpServlet {
	private static final long serialVersionUID = 1L;

	public Admin() {
		super();
	}

	// ✅ If someone opens /Admin directly in browser
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		// redirect to login page
		response.sendRedirect("Login.jsp");
	}

	// ✅ Handles login form submission
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		String username = request.getParameter("email");
		String password = request.getParameter("pwd");

		try {
			Connection con = DBConnection.connect();
			PreparedStatement ptmt = con.prepareStatement(
					"select * from admin where username=? and password=?");
			ptmt.setString(1, username);
			ptmt.setString(2, password);

			ResultSet rs = ptmt.executeQuery();

			if (rs.next()) {
				int adminId = rs.getInt("admin_id");

				// Create session
				HttpSession session = request.getSession();
				session.setAttribute("userId", adminId);
				session.setAttribute("email", username);
				session.setAttribute("AdminLoggedIn", "Admin LoggedIn Successfully");

				// Generate JWT token
				String token = JWTUtils.generateToken(username, "ADMIN");

				// Store JWT in cookie
				Cookie jwtCookie = new Cookie("jwtToken", token);
				jwtCookie.setHttpOnly(true);
				jwtCookie.setPath("/");
				response.addCookie(jwtCookie);

				// ✅ Redirect to admin dashboard
				response.sendRedirect("AdminDash.jsp");
				return;

			} else {
				HttpSession session = request.getSession();
				session.setAttribute("UserLoginError", "Invalid email or password");
				response.sendRedirect("Login.jsp");
			}

		} catch (Exception e) {
			e.printStackTrace();
			response.sendRedirect("Login.jsp");
		}
	}
}
