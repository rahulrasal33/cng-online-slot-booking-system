package CngBooking;

import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

import com.DbConnection.DBConnection;

public class UserOrders extends HttpServlet {
    private static final long serialVersionUID = 1L;

    public UserOrders() { super(); }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("Login.jsp?error=Please login first");
            return;
        }
        System.out.println("UserOrders servlet called");


        int userId = (int) session.getAttribute("userId");
        List<String[]> orders = new ArrayList<>();
        
        // Check for booking success message from session
        String bookingSuccess = (String) session.getAttribute("BookingSuccess");
        if (bookingSuccess != null) {
            request.setAttribute("bookingSuccess", bookingSuccess);
            // Clear the message so it doesn't show again on refresh
            session.removeAttribute("BookingSuccess");
        }

        Connection con = null;
        try {
            con = DBConnection.connect();
            if (con == null) {
                System.out.println("UserOrders: Database connection failed");
                request.setAttribute("error", "Database connection failed. Please try again.");
                RequestDispatcher rd = request.getRequestDispatcher("UserOrdersDash.jsp");
                rd.forward(request, response);
                return;
            }
            
            // Fetch from slot_bookings table with pump name
            // Join with cng_pumps table using pump_id
            String query = "SELECT sb.booking_id, sb.pump_id, " +
                    "sb.booking_date, sb.slot_time, sb.vehicle_type, sb.vehicle_number, sb.status, " +
                    "sb.created_at, cp.pump_name " +
                    "FROM slot_bookings sb " +
                    "LEFT JOIN cng_pumps cp ON sb.pump_id = cp.pump_id " +
                    "WHERE sb.user_id = ? " +
                    "ORDER BY sb.booking_date DESC, sb.slot_time DESC";
            
            System.out.println("UserOrders: Executing query for user_id: " + userId);
            PreparedStatement pst = con.prepareStatement(query);
            pst.setInt(1, userId);

            ResultSet rs = pst.executeQuery();
            int count = 0;
            while (rs.next()) {
                count++;
                String[] row = new String[9];
                row[0] = String.valueOf(rs.getInt("booking_id"));
                
                // Get pump name from join, fallback to pump_id if not found
                String pumpName = rs.getString("pump_name");
                if (pumpName == null || pumpName.isEmpty()) {
                    pumpName = "Station #" + rs.getInt("pump_id");
                }
                row[1] = pumpName;
                
                row[2] = rs.getDate("booking_date") != null ? rs.getDate("booking_date").toString() : "N/A";
                row[3] = rs.getString("slot_time") != null ? rs.getString("slot_time") : "N/A";
                row[4] = rs.getString("vehicle_type") != null ? rs.getString("vehicle_type") : "N/A";
                row[5] = rs.getString("vehicle_number") != null ? rs.getString("vehicle_number") : "N/A";
                row[6] = rs.getString("status") != null ? rs.getString("status") : "CONFIRMED";
                row[7] = "41.30"; // Payment amount (Platform Fees ₹30 + Service ₹5 + Tax ₹6.30)
                row[8] = String.valueOf(rs.getInt("pump_id")); // Store pump_id for reference
                
                orders.add(row);
            }
            
            rs.close();
            pst.close();
            
            System.out.println("UserOrders: Found " + count + " bookings for user_id: " + userId);

            // ✅ Attach orders to request
            request.setAttribute("orders", orders);

            // ✅ Forward (NOT redirect!)
            RequestDispatcher rd = request.getRequestDispatcher("UserOrdersDash.jsp");
            rd.forward(request, response);

        } catch (SQLException e) {
            e.printStackTrace();
            System.out.println("UserOrders: SQLException - " + e.getMessage());
            System.out.println("UserOrders: SQLState - " + e.getSQLState());
            request.setAttribute("error", "Database error: " + e.getMessage());
            try {
                RequestDispatcher rd = request.getRequestDispatcher("UserOrdersDash.jsp");
                rd.forward(request, response);
            } catch (Exception ex) {
                ex.printStackTrace();
                response.sendRedirect("Login.jsp?error=An error occurred. Please try again.");
            }
        } catch (Exception e) {
            e.printStackTrace();
            System.out.println("UserOrders: Exception - " + e.getMessage());
            request.setAttribute("error", "An error occurred: " + e.getMessage());
            try {
                RequestDispatcher rd = request.getRequestDispatcher("UserOrdersDash.jsp");
                rd.forward(request, response);
            } catch (Exception ex) {
                ex.printStackTrace();
                response.sendRedirect("Login.jsp?error=An error occurred. Please try again.");
            }
        } finally {
            try {
                if (con != null) con.close();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
