package CngBooking;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;
import javax.servlet.ServletException;
import javax.servlet.http.*;



import com.DbConnection.DBConnection;
import org.json.JSONArray;
import org.json.JSONObject;


public class PumpDataServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private static JSONArray getFallbackPumps() {
        JSONArray pumpsArray = new JSONArray();

        String[][] sampleStations = {
            {"1", "Pune Live CNG Station", "18.5314", "73.8446", "Pune", "Shivajinagar, Near JM Road", "9876543210", "85.00", "APPROVED"},
            {"2", "Saraswati CNG Hub", "18.5204", "73.8567", "Pune", "FC Road, Opposite City Center", "9876543211", "87.50", "OPEN"},
            {"3", "Aundh Green Fuel", "18.5598", "73.8039", "Pune", "Aundh, Near IT Park", "9876543212", "86.00", "APPROVED"},
            {"4", "Kharadi Fast Fuel", "18.5503", "73.9347", "Pune", "Kharadi, Near EON IT Park", "9876543213", "88.00", "OPEN"}
        };

        for (String[] station : sampleStations) {
            JSONObject pump = new JSONObject();
            pump.put("id", Integer.parseInt(station[0]));
            pump.put("name", station[1]);
            pump.put("lat", Double.parseDouble(station[2]));
            pump.put("lng", Double.parseDouble(station[3]));
            pump.put("city", station[4]);
            pump.put("address", station[5]);
            pump.put("phone", station[6]);
            pump.put("price_per_kg", station[7]);
            pump.put("status", station[8]);
            pumpsArray.put(pump);
        }

        return pumpsArray;
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {

        response.setContentType("application/json");
        PrintWriter out = response.getWriter();

        Connection con = null;
        try {
            con = DBConnection.connect();
            if (con == null) {
                out.print(getFallbackPumps().toString());
                return;
            }

            // Try cng_pumps first (newer table structure)
            String query = "SELECT pump_id, pump_name, latitude, longitude, city, address, mobileNo, price_per_kg, status FROM cng_pumps";
            PreparedStatement pst = null;
            ResultSet rs = null;
            
            try {
                pst = con.prepareStatement(query);
                rs = pst.executeQuery();
            } catch (SQLException e) {
                // If cng_pumps doesn't exist, try cng_pump (older structure)
                try {
                    if (rs != null) rs.close();
                    if (pst != null) pst.close();
                } catch (SQLException closeEx) {
                    // Ignore close errors
                }
                query = "SELECT cng_id, pump_name, latitude, longitude, city, address, mobileNo, price_per_kg, status FROM cng_pump";
                pst = con.prepareStatement(query);
                rs = pst.executeQuery();
            }

            JSONArray pumpsArray = new JSONArray();

            while (rs.next()) {
                JSONObject pump = new JSONObject();
                try {
                    // Try pump_id first (cng_pumps), fallback to cng_id (cng_pump)
                    pump.put("id", rs.getInt("pump_id"));
                } catch (SQLException e) {
                    pump.put("id", rs.getInt("cng_id"));
                }
                pump.put("name", rs.getString("pump_name"));
                double latitude = rs.getDouble("latitude");
                pump.put("lat", rs.wasNull() ? JSONObject.NULL : latitude);
                double longitude = rs.getDouble("longitude");
                pump.put("lng", rs.wasNull() ? JSONObject.NULL : longitude);
                pump.put("city", rs.getString("city"));
                pump.put("address", rs.getString("address"));
                pump.put("phone", rs.getString("mobileNo"));
                
                // Add price if available
                try {
                    Object price = rs.getObject("price_per_kg");
                    pump.put("price_per_kg", price != null ? price.toString() : "N/A");
                } catch (SQLException e) {
                    pump.put("price_per_kg", "N/A");
                }
                
                // Add status if available
                try {
                    String status = rs.getString("status");
                    pump.put("status", status != null ? status : "UNKNOWN");
                } catch (SQLException e) {
                    pump.put("status", "UNKNOWN");
                }

                pumpsArray.put(pump);
            }
            
            if (rs != null) rs.close();
            if (pst != null) pst.close();

            out.print(pumpsArray.toString());

        } catch (Exception e) {
            e.printStackTrace();
            out.print(getFallbackPumps().toString());
        } finally {
            if (con != null) {
                try { con.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
        }
    }
}
