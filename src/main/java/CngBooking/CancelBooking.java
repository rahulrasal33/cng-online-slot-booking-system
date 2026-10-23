package CngBooking;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.json.JSONObject;

import com.DbConnection.DBConnection;

//@WebServlet("/CancelBooking")
public class CancelBooking extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    // Payment amount constant (Platform Fees ₹30 + Service ₹5 + Tax ₹6.30)
    private static final double PAYMENT_AMOUNT = 41.30;

    public CancelBooking() {
        super();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        JSONObject jsonResponse = new JSONObject();
        
        HttpSession session = request.getSession(false);
        
        // Check if user is logged in
        if (session == null || session.getAttribute("userId") == null) {
            jsonResponse.put("success", false);
            jsonResponse.put("message", "Please login first");
            out.print(jsonResponse.toString());
            out.flush();
            return;
        }
        
        int userId = (int) session.getAttribute("userId");
        String bookingIdStr = request.getParameter("bookingId");
        
        if (bookingIdStr == null || bookingIdStr.trim().isEmpty()) {
            jsonResponse.put("success", false);
            jsonResponse.put("message", "Booking ID is required");
            out.print(jsonResponse.toString());
            out.flush();
            return;
        }
        
        int bookingId;
        try {
            bookingId = Integer.parseInt(bookingIdStr);
        } catch (NumberFormatException e) {
            jsonResponse.put("success", false);
            jsonResponse.put("message", "Invalid booking ID");
            out.print(jsonResponse.toString());
            out.flush();
            return;
        }
        
        Connection con = null;
        try {
            con = DBConnection.connect();
            if (con == null) {
                jsonResponse.put("success", false);
                jsonResponse.put("message", "Database connection failed");
                out.print(jsonResponse.toString());
                out.flush();
                return;
            }
            
            // First, verify the booking belongs to this user and is in a cancellable state
            String checkQuery = "SELECT booking_id, status, booking_date, slot_time " +
                    "FROM slot_bookings " +
                    "WHERE booking_id = ? AND user_id = ?";
            
            PreparedStatement checkPst = con.prepareStatement(checkQuery);
            checkPst.setInt(1, bookingId);
            checkPst.setInt(2, userId);
            ResultSet rs = checkPst.executeQuery();
            
            if (!rs.next()) {
                jsonResponse.put("success", false);
                jsonResponse.put("message", "Booking not found or you don't have permission to cancel it");
                rs.close();
                checkPst.close();
                out.print(jsonResponse.toString());
                out.flush();
                return;
            }
            
            String currentStatus = rs.getString("status");
            rs.close();
            checkPst.close();
            
            // Check if booking can be cancelled (only CONFIRMED bookings can be cancelled)
            if (currentStatus != null && !"CONFIRMED".equalsIgnoreCase(currentStatus)) {
                jsonResponse.put("success", false);
                jsonResponse.put("message", "This booking cannot be cancelled. Current status: " + currentStatus);
                out.print(jsonResponse.toString());
                out.flush();
                return;
            }
            
            // Update booking status to CANCELLED
            String updateQuery = "UPDATE slot_bookings SET status = 'CANCELLED' WHERE booking_id = ? AND user_id = ?";
            PreparedStatement updatePst = con.prepareStatement(updateQuery);
            updatePst.setInt(1, bookingId);
            updatePst.setInt(2, userId);
            
            int rowsAffected = updatePst.executeUpdate();
            updatePst.close();
            
            if (rowsAffected > 0) {
                // Log refund information (in a real system, you would integrate with payment gateway)
                System.out.println("=== BOOKING CANCELLED ===");
                System.out.println("Booking ID: " + bookingId);
                System.out.println("User ID: " + userId);
                System.out.println("Refund Amount: ₹" + PAYMENT_AMOUNT);
                System.out.println("Status: CANCELLED");
                System.out.println("========================");
                
                jsonResponse.put("success", true);
                jsonResponse.put("message", "Booking cancelled successfully");
                jsonResponse.put("refundAmount", PAYMENT_AMOUNT);
                jsonResponse.put("bookingId", bookingId);
            } else {
                jsonResponse.put("success", false);
                jsonResponse.put("message", "Failed to cancel booking. Please try again.");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            System.out.println("CancelBooking: Exception occurred - " + e.getMessage());
            e.printStackTrace();
            jsonResponse.put("success", false);
            String errorMsg = e.getMessage();
            if (errorMsg == null) errorMsg = "Unknown error occurred";
            jsonResponse.put("message", "An error occurred: " + errorMsg);
        } finally {
            try {
                if (con != null) con.close();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        
        // Ensure response is sent
        try {
            String responseStr = jsonResponse.toString();
            System.out.println("CancelBooking: Sending response - " + responseStr);
            out.print(responseStr);
            out.flush();
        } catch (Exception e) {
            System.out.println("CancelBooking: Error sending response - " + e.getMessage());
            e.printStackTrace();
        }
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doPost(request, response);
    }
}
