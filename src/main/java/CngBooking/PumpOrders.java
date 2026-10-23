package CngBooking;

import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.http.*;

import com.DbConnection.DBConnection;

public class PumpOrders extends HttpServlet {
    private static final long serialVersionUID = 1L;

    public PumpOrders() { super(); }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("pumpId") == null) {
            response.sendRedirect("Login.jsp?error=Please login first");
            return;
        }
        
        int pumpId = (int) session.getAttribute("pumpId");
        System.out.println("Fetching bookings for pump_id: " + pumpId);
        
        List<String[]> orders = new ArrayList<>();

        Connection con = null;
        try {
            con = DBConnection.connect();
            if (con == null) {
                request.setAttribute("error", "Database connection failed");
                RequestDispatcher rd = request.getRequestDispatcher("PumpOrderDash.jsp");
                rd.forward(request, response);
                return;
            }

            String yearParam = request.getParameter("year");
            String monthParam = request.getParameter("month");
            
            // Query slot_bookings table directly - it has all customer info
            String query = "SELECT booking_id, full_name, phone, booking_date, slot_time, " +
                    "vehicle_type, vehicle_number, email " +
                    "FROM slot_bookings " +
                    "WHERE pump_id = ?";
            
            // Add date filtering if provided
            boolean hasDateFilter = false;
            if (yearParam != null && monthParam != null && 
                !yearParam.equals("ALL") && !monthParam.equals("ALL")) {
                query += " AND booking_date LIKE ?";
                hasDateFilter = true;
            }
            query += " ORDER BY booking_date DESC, slot_time ASC";

            PreparedStatement pst = con.prepareStatement(query);
            pst.setInt(1, pumpId);
            
            if (hasDateFilter) {
                String monthFormatted = String.format("%02d", Integer.parseInt(monthParam));
                pst.setString(2, yearParam + "-" + monthFormatted + "%");
            }

            System.out.println("Executing query: " + query);
            System.out.println("With pump_id: " + pumpId);

            ResultSet rs = pst.executeQuery();
            int count = 0;
            
            while (rs.next()) {
                count++;
                String[] row = new String[8];
                row[0] = String.valueOf(rs.getInt("booking_id"));
                row[1] = rs.getString("full_name") != null ? rs.getString("full_name") : "N/A";
                row[2] = rs.getString("phone") != null ? rs.getString("phone") : "N/A";
                row[3] = rs.getDate("booking_date") != null ? rs.getDate("booking_date").toString() : "N/A";
                row[4] = rs.getString("slot_time") != null ? rs.getString("slot_time") : "N/A";
                row[5] = rs.getString("vehicle_type") != null ? rs.getString("vehicle_type") : "N/A";
                row[6] = rs.getString("vehicle_number") != null ? rs.getString("vehicle_number") : "N/A";
                row[7] = rs.getString("email") != null ? rs.getString("email") : "N/A";
                orders.add(row);
            }
            
            rs.close();
            pst.close();
            
            System.out.println("Found " + count + " bookings for pump_id: " + pumpId);

            request.setAttribute("orders", orders);
            RequestDispatcher rd = request.getRequestDispatcher("PumpOrderDash.jsp");
            rd.forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            System.out.println("Error fetching bookings: " + e.getMessage());
            request.setAttribute("error", "Error loading bookings: " + e.getMessage());
            RequestDispatcher rd = request.getRequestDispatcher("PumpOrderDash.jsp");
            rd.forward(request, response);
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
