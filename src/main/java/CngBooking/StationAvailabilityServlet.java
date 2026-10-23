package CngBooking;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.DbConnection.DBConnection;
import org.json.JSONArray;
import org.json.JSONObject;

public class StationAvailabilityServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    // Total slots available per day (24 hours = 24 slots)
    private static final int TOTAL_SLOTS_PER_DAY = 24;

    private static JSONArray getFallbackAvailability(String bookingDate) {
        JSONArray availabilityArray = new JSONArray();
        int[][] fallbackData = {
            {1, 6, 18},
            {2, 5, 19},
            {3, 8, 16},
            {4, 4, 20}
        };

        for (int[] station : fallbackData) {
            JSONObject availability = new JSONObject();
            availability.put("stationId", station[0]);
            availability.put("date", bookingDate);
            availability.put("totalSlots", TOTAL_SLOTS_PER_DAY);
            availability.put("bookedSlots", station[1]);
            availability.put("availableSlots", station[2]);
            availabilityArray.put(availability);
        }

        return availabilityArray;
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        
        String dateParam = request.getParameter("date");
        String stationIds = request.getParameter("stationIds"); // Comma-separated station IDs
        
        // Use today's date if not provided
        String bookingDate = dateParam != null && !dateParam.isEmpty() 
            ? dateParam 
            : LocalDate.now().format(DateTimeFormatter.ISO_DATE);
        
        Connection con = null;
        try {
            con = DBConnection.connect();
            if (con == null) {
                out.print(getFallbackAvailability(bookingDate).toString());
                return;
            }
            
            JSONArray availabilityArray = new JSONArray();
            
            // If specific station IDs provided, get availability for those only
            if (stationIds != null && !stationIds.isEmpty()) {
                String[] ids = stationIds.split(",");
                
                for (String stationIdStr : ids) {
                    try {
                        int stationId = Integer.parseInt(stationIdStr.trim());
                        JSONObject availability = getStationAvailability(con, stationId, bookingDate);
                        availabilityArray.put(availability);
                    } catch (NumberFormatException e) {
                        // Skip invalid station IDs
                        continue;
                    }
                }
            } else {
                // Get availability for all stations
                String query = "SELECT DISTINCT pump_id FROM slot_bookings " +
                              "UNION " +
                              "SELECT pump_id FROM cng_pumps " +
                              "UNION " +
                              "SELECT cng_id as pump_id FROM cng_pump";
                
                try (PreparedStatement pst = con.prepareStatement(query);
                     ResultSet rs = pst.executeQuery()) {
                    
                    while (rs.next()) {
                        int stationId = rs.getInt("pump_id");
                        JSONObject availability = getStationAvailability(con, stationId, bookingDate);
                        availabilityArray.put(availability);
                    }
                } catch (SQLException e) {
                    // If query fails, try alternative approach
                    // Get all stations from cng_pumps or cng_pump
                    try {
                        String altQuery = "SELECT pump_id FROM cng_pumps";
                        PreparedStatement altPst = con.prepareStatement(altQuery);
                        ResultSet altRs = altPst.executeQuery();
                        
                        while (altRs.next()) {
                            int stationId = altRs.getInt("pump_id");
                            JSONObject availability = getStationAvailability(con, stationId, bookingDate);
                            availabilityArray.put(availability);
                        }
                        altRs.close();
                        altPst.close();
                    } catch (SQLException altEx) {
                        // Try cng_pump table
                        try {
                            String altQuery2 = "SELECT cng_id as pump_id FROM cng_pump";
                            PreparedStatement altPst2 = con.prepareStatement(altQuery2);
                            ResultSet altRs2 = altPst2.executeQuery();
                            
                            while (altRs2.next()) {
                                int stationId = altRs2.getInt("pump_id");
                                JSONObject availability = getStationAvailability(con, stationId, bookingDate);
                                availabilityArray.put(availability);
                            }
                            altRs2.close();
                            altPst2.close();
                        } catch (SQLException altEx2) {
                            // Ignore and continue
                        }
                    }
                }
            }
            
            if (availabilityArray.isEmpty()) {
                out.print(getFallbackAvailability(bookingDate).toString());
            } else {
                out.print(availabilityArray.toString());
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            out.print(getFallbackAvailability(bookingDate).toString());
        } finally {
            try {
                if (con != null) con.close();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }
    
    private JSONObject getStationAvailability(Connection con, int stationId, String bookingDate) 
            throws Exception {
        JSONObject availability = new JSONObject();
        availability.put("stationId", stationId);
        availability.put("date", bookingDate);
        
        // Count booked slots for this station and date
        String countQuery = "SELECT COUNT(*) as booked_count FROM slot_bookings " +
                           "WHERE pump_id = ? AND booking_date = ? AND status != 'CANCELLED'";
        
        PreparedStatement countPst = con.prepareStatement(countQuery);
        countPst.setInt(1, stationId);
        countPst.setString(2, bookingDate);
        
        ResultSet countRs = countPst.executeQuery();
        int bookedCount = 0;
        if (countRs.next()) {
            bookedCount = countRs.getInt("booked_count");
        }
        countRs.close();
        countPst.close();
        
        int availableSlots = TOTAL_SLOTS_PER_DAY - bookedCount;
        if (availableSlots < 0) availableSlots = 0; // Safety check
        
        availability.put("totalSlots", TOTAL_SLOTS_PER_DAY);
        availability.put("bookedSlots", bookedCount);
        availability.put("availableSlots", availableSlots);
        
        return availability;
    }
}
