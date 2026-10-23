package com.servlets;

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

import com.DbConnection.DBConnection;

// ✅ FIX: Completed the empty NearbyStationsServlet
@WebServlet("/nearbyStations")
public class NearbyStationsServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        String latParam = request.getParameter("lat");
        String lngParam = request.getParameter("lng");

        if (latParam == null || lngParam == null) {
            out.print("{\"error\": \"Missing lat/lng parameters\"}");
            return;
        }

        double userLat, userLng;
        try {
            userLat = Double.parseDouble(latParam);
            userLng = Double.parseDouble(lngParam);
        } catch (NumberFormatException e) {
            out.print("{\"error\": \"Invalid lat/lng values\"}");
            return;
        }

        Connection con = null;
        try {
            con = DBConnection.connect();
            if (con == null) {
                out.print("{\"error\": \"Database connection failed\"}");
                return;
            }

            // Haversine formula in SQL to find nearby stations within 50 km, sorted by distance
            String sql = "SELECT pump_id, pump_name, address, city, latitude, longitude, " +
                    "price_per_kg, cng_kg, open_time, close_time, status, " +
                    "(6371 * ACOS(COS(RADIANS(?)) * COS(RADIANS(latitude)) * " +
                    "COS(RADIANS(longitude) - RADIANS(?)) + SIN(RADIANS(?)) * SIN(RADIANS(latitude)))) " +
                    "AS distance_km " +
                    "FROM cng_pumps " +
                    "WHERE status = 'APPROVED' AND latitude IS NOT NULL AND longitude IS NOT NULL " +
                    "HAVING distance_km < 50 " +
                    "ORDER BY distance_km ASC " +
                    "LIMIT 20";

            PreparedStatement pst = con.prepareStatement(sql);
            pst.setDouble(1, userLat);
            pst.setDouble(2, userLng);
            pst.setDouble(3, userLat);

            ResultSet rs = pst.executeQuery();

            StringBuilder json = new StringBuilder("[");
            boolean first = true;
            while (rs.next()) {
                if (!first) json.append(",");
                first = false;
                json.append("{")
                    .append("\"pump_id\":").append(rs.getInt("pump_id")).append(",")
                    .append("\"pump_name\":\"").append(escapeJson(rs.getString("pump_name"))).append("\",")
                    .append("\"address\":\"").append(escapeJson(rs.getString("address"))).append("\",")
                    .append("\"city\":\"").append(escapeJson(rs.getString("city"))).append("\",")
                    .append("\"latitude\":").append(rs.getDouble("latitude")).append(",")
                    .append("\"longitude\":").append(rs.getDouble("longitude")).append(",")
                    .append("\"price_per_kg\":").append(rs.getDouble("price_per_kg")).append(",")
                    .append("\"cng_kg\":").append(rs.getInt("cng_kg")).append(",")
                    .append("\"open_time\":\"").append(escapeJson(rs.getString("open_time"))).append("\",")
                    .append("\"close_time\":\"").append(escapeJson(rs.getString("close_time"))).append("\",")
                    .append("\"distance_km\":").append(String.format("%.2f", rs.getDouble("distance_km")))
                    .append("}");
            }
            json.append("]");

            rs.close();
            pst.close();
            out.print(json.toString());

        } catch (Exception e) {
            e.printStackTrace();
            out.print("{\"error\": \"" + escapeJson(e.getMessage()) + "\"}");
        } finally {
            try { if (con != null) con.close(); } catch (Exception e) { e.printStackTrace(); }
        }
    }

    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"");
    }
}
