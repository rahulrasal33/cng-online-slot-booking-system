//package CngBooking;
//
//import java.io.IOException;
//import java.io.PrintWriter;
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
//public class ULogin extends HttpServlet {
//    private static final long serialVersionUID = 1L;
//
//    public ULogin() {
//        super();
//    }
//
//    @Override
//    protected void doPost(HttpServletRequest request, HttpServletResponse response)
//            throws ServletException, IOException {
//
//        String email = request.getParameter("email");
//        String pass = request.getParameter("pwd");
//        System.out.println("Login attempt: " + email);
//
//        response.setContentType("application/json");
//        PrintWriter out = response.getWriter();
//
//        try {
//            Connection con = DBConnection.connect();
//            PreparedStatement ptmt = con.prepareStatement("SELECT * FROM user WHERE email=? AND password=?");
//            ptmt.setString(1, email);
//            ptmt.setString(2, pass);
//            ResultSet rs = ptmt.executeQuery();
//
//            if (rs.next()) {
//            	 int userId = rs.getInt("uid"); 
//                String name = rs.getString("name");   // assuming 2nd column = name
//                String mob = rs.getString("mobile"); // adjust column name if needed
//                String city = rs.getString("city");  // only if your table has city column
//
//                // Store in helper (if still needed)
//                GetSet.setN(name);
//                GetSet.setMobile(mob);
//
//                // Create session
//                HttpSession session = request.getSession();
//                session.setAttribute("userId", userId); 
//                session.setAttribute("name", name);
//                session.setAttribute("email", email);
//                session.setAttribute("mobile", mob);
//                session.setAttribute("city", city != null ? city : "N/A");
//                session.setAttribute("memberSince", "Jan 2024"); // example, replace with DB value if available
//
//                // Generate JWT token
//                String token = JWTUtils.generateToken(email ,"USER");
//
//                // Store JWT in cookie
//                Cookie jwtCookie = new Cookie("jwtToken", token);
//                jwtCookie.setHttpOnly(true);  // JS can't access
//                jwtCookie.setPath("/");       // available across app
//                response.addCookie(jwtCookie);
//                HttpSession newSession = request.getSession();
//			     newSession.setAttribute("UserLoggedin", "User LoggedIn SuccessFully");
//                // ✅ Redirect to home page
//                response.sendRedirect("Home1.jsp");
//
//            } else {
//                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
//                HttpSession newSession = request.getSession();
//			     newSession.setAttribute("UserLoginError", "Invalid email or password");
//	             response.sendRedirect("Login.jsp");
//
//                out.print("{\"status\":\"fail\",\"message\":\"Invalid email or password\"}");
//            }
//        } catch (Exception e) {
//            e.printStackTrace();
//            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
//            out.print("{\"status\":\"error\",\"message\":\"Something went wrong\"}");
//        }
//    }
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
import com.DbConnection.GetSet;

public class ULogin extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String email = request.getParameter("email");
        String pass = request.getParameter("pwd");

        try {
            Connection con = DBConnection.connect();
            PreparedStatement ptmt = con.prepareStatement(
                    "SELECT * FROM users WHERE email=? AND password=?");
            ptmt.setString(1, email);
            ptmt.setString(2, pass);

            ResultSet rs = ptmt.executeQuery();

            if (rs.next()) {
            	
               int userId = rs.getInt("user_id");
               String name = rs.getString("full_name");
               String mail = rs.getString("email");
               String mob = rs.getString("phone");
            	 
            	 
            	HttpSession session=request.getSession(true);
            	session.setAttribute("userId",userId);
            	session.setAttribute("name",name);
            	session.setAttribute("email",email);
            	session.setAttribute("mobile",mob);
            	session.setAttribute("role","USER"); // Set role in session for navbar detection
//               
////                String city = rs.getString("city");
//
//                // Optional helper
//                GetSet.setN(name);
//                GetSet.setMobile(mob);

                // Create session
//                HttpSession session = request.getSession();
//                session.setAttribute("userId", userId);
//                session.setAttribute("name", name);
//                session.setAttribute("email", email);
//                session.setAttribute("mobile", mob);
//                session.setAttribute("city", city != null ? city : "N/A");
//                session.setAttribute("UserLoggedin", "User LoggedIn Successfully");
                System.out.println("LOGIN SUCCESS,userId="+userId);

                // JWT (optional – keep if needed)
                String token = JWTUtils.generateToken(email, "USER");
                Cookie jwtCookie = new Cookie("jwtToken", token);
                jwtCookie.setHttpOnly(true);
                jwtCookie.setPath("/");
                response.addCookie(jwtCookie);

                // ✅ Redirect to USER home
                response.sendRedirect("Home1.jsp");
                return;

            } else {
                HttpSession session = request.getSession();
                session.setAttribute("UserLoginError", "Invalid email or password");
                response.sendRedirect("Login.jsp");
                return;
            }

        } catch (Exception e) {
            e.printStackTrace();
            HttpSession session = request.getSession();
            session.setAttribute("UserLoginError", "Something went wrong");
            response.sendRedirect("Login.jsp");
        }
    }
}
