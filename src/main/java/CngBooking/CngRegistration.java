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

public class CngRegistration extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String pumpName = value(request, "pname");
        String address = value(request, "address");
        String city = value(request, "city");
        String taluka = value(request, "taluka");
        String district = value(request, "district");
        String state = value(request, "state");
        String mobile = value(request, "mobile");
        String email = value(request, "email");
        String password = value(request, "pwd");
        String price = value(request, "price_per_kg");
        String openTime = value(request, "open_time");
        String closeTime = value(request, "close_time");
        String latStr = value(request, "latitude");
        String lngStr = value(request, "longitude");
        Double latitude;
        Double longitude;

        try {
            latitude = coordinate(latStr, "Latitude", -90, 90);
            longitude = coordinate(lngStr, "Longitude", -180, 180);
        } catch (IllegalArgumentException e) {
            showError(request, response, e.getMessage());
            return;
        }

        if (pumpName.isEmpty() || address.isEmpty() || city.isEmpty() || mobile.isEmpty()
                || email.isEmpty() || password.isEmpty()) {
            showError(request, response, "Please fill in all required seller fields.");
            return;
        }

        if (price.isEmpty()) {
            price = "85.00";
        }

        try (Connection con = DBConnection.connect()) {
            if (con == null) {
                showError(request, response,
                        "Unable to connect to the database. Please check that MySQL is running and configured.");
                return;
            }

            String sql = "INSERT INTO cng_pumps(" +
                    "pump_name,address,city,taluka,district,state," +
                    "mobileNo,email,password,price_per_kg,open_time,close_time," +
                    "latitude,longitude,cng_kg,status) " +
                    "VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,1000,'PENDING')";

            try (PreparedStatement pst = con.prepareStatement(sql)) {
                pst.setString(1, pumpName);
                pst.setString(2, address);
                pst.setString(3, city);
                pst.setString(4, taluka);
                pst.setString(5, district);
                pst.setString(6, state);
                pst.setString(7, mobile);
                pst.setString(8, email);
                pst.setString(9, password);
                pst.setString(10, price);
                pst.setString(11, openTime.isEmpty() ? "06:00" : openTime);
                pst.setString(12, closeTime.isEmpty() ? "22:00" : closeTime);
                if (latitude != null) {
                    pst.setDouble(13, latitude);
                } else {
                    pst.setNull(13, java.sql.Types.DOUBLE);
                }
                if (longitude != null) {
                    pst.setDouble(14, longitude);
                } else {
                    pst.setNull(14, java.sql.Types.DOUBLE);
                }

                pst.executeUpdate();
            }

            HttpSession session = request.getSession();
            session.setAttribute("PumpRegistered", "Registration submitted. Wait for admin approval.");
            response.sendRedirect("Login.jsp");
        } catch (SQLException e) {
            e.printStackTrace();
            if ("23000".equals(e.getSQLState())) {
                showError(request, response, "A seller account with this email or phone number already exists.");
                return;
            }
            showError(request, response, "Seller registration failed. Please check the database setup and try again.");
        } catch (Exception e) {
            e.printStackTrace();
            showError(request, response, "Please check the seller details and try again.");
        }
    }

    private static String value(HttpServletRequest request, String parameter) {
        String value = request.getParameter(parameter);
        return value == null ? "" : value.trim();
    }

    private static Double coordinate(String value, String label, double minimum, double maximum) {
        if (value.isEmpty()) {
            return null;
        }

        try {
            double coordinate = Double.parseDouble(value);
            if (!Double.isFinite(coordinate) || coordinate < minimum || coordinate > maximum) {
                throw new IllegalArgumentException();
            }
            return coordinate;
        } catch (IllegalArgumentException e) {
            throw new IllegalArgumentException(label + " must be between " + minimum + " and " + maximum + ".");
        }
    }

    private static void showError(HttpServletRequest request, HttpServletResponse response, String message)
            throws ServletException, IOException {
        request.setAttribute("SignupError", message);
        request.getRequestDispatcher("signup.jsp").forward(request, response);
    }
}
