package CngBooking;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.text.SimpleDateFormat;
import java.util.Date;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.DbConnection.DBConnection;

public class DownloadReceipt extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private static String escapeHtmlAttribute(String value) {
        return value.replace("&", "&amp;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;")
                .replace("<", "&lt;")
                .replace(">", "&gt;");
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("Login.jsp?error=Please login first");
            return;
        }

        int userId = (int) session.getAttribute("userId");
        String bookingIdStr = request.getParameter("bookingId");

        if (bookingIdStr == null || bookingIdStr.trim().isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Booking ID is required");
            return;
        }

        int bookingId;
        try {
            bookingId = Integer.parseInt(bookingIdStr);
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid booking ID");
            return;
        }

        Connection con = null;
        try {
            con = DBConnection.connect();
            if (con == null) {
                response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Database connection failed");
                return;
            }

            String query = "SELECT sb.booking_id, sb.pump_id, sb.booking_date, sb.slot_time, " +
                    "sb.vehicle_type, sb.vehicle_number, sb.status, sb.created_at, " +
                    "sb.full_name, sb.phone, sb.email, " +
                    "cp.pump_name, cp.address, cp.city " +
                    "FROM slot_bookings sb " +
                    "LEFT JOIN cng_pumps cp ON sb.pump_id = cp.pump_id " +
                    "WHERE sb.booking_id = ? AND sb.user_id = ?";

            PreparedStatement pst = con.prepareStatement(query);
            pst.setInt(1, bookingId);
            pst.setInt(2, userId);
            ResultSet rs = pst.executeQuery();

            if (!rs.next()) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Booking not found");
                rs.close(); pst.close();
                return;
            }

            String pumpName   = rs.getString("pump_name")   != null ? rs.getString("pump_name")   : "Station #" + rs.getInt("pump_id");
            String city       = rs.getString("city")        != null ? rs.getString("city")        : "";
            String address    = rs.getString("address")     != null ? rs.getString("address")     : "";
            String bookDate   = String.valueOf(rs.getDate("booking_date"));
            String slotTime   = rs.getString("slot_time")   != null ? rs.getString("slot_time")   : "";
            String vehType    = rs.getString("vehicle_type")   != null ? rs.getString("vehicle_type")   : "N/A";
            String vehNum     = rs.getString("vehicle_number") != null ? rs.getString("vehicle_number") : "N/A";
            String custName   = rs.getString("full_name")   != null ? rs.getString("full_name")   : "N/A";
            String custPhone  = rs.getString("phone")       != null ? rs.getString("phone")       : "N/A";
            String custEmail  = rs.getString("email")       != null ? rs.getString("email")       : "N/A";
            String status     = rs.getString("status")      != null ? rs.getString("status")      : "CONFIRMED";
            String createdAt  = rs.getTimestamp("created_at") != null
                    ? new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(rs.getTimestamp("created_at")) : "N/A";

            String qrData = "BOOKING:" + bookingId
                    + "|PUMP_ID:" + rs.getInt("pump_id")
                    + "|PUMP:" + pumpName
                    + "|DATE:" + bookDate
                    + "|SLOT:" + slotTime
                    + "|STATUS:" + status;

            response.setContentType("text/html; charset=UTF-8");
            response.setHeader("Content-Disposition", "inline; filename=receipt_" + bookingId + ".html");

            PrintWriter out = response.getWriter();

            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<meta charset='UTF-8'>");
            out.println("<title>Booking Receipt #" + bookingId + "</title>");
            out.println("<style>");
            out.println("body{font-family:Arial,sans-serif;margin:0;background:#0b0f19;color:#e5e5e5;display:flex;justify-content:center;align-items:flex-start;padding:30px;}");
            out.println(".receipt{background:#111827;padding:36px;max-width:620px;width:100%;border-radius:14px;box-shadow:0 0 30px rgba(0,255,102,0.15);}");
            out.println(".header{text-align:center;border-bottom:2px solid #00ff66;padding-bottom:20px;margin-bottom:24px;}");
            out.println(".header h1{color:#00ff66;font-size:2rem;margin:0;letter-spacing:2px;}");
            out.println(".header p{color:#9ca3af;margin:6px 0 0;}");
            out.println(".badge{display:inline-block;background:#00ff66;color:#111;padding:4px 14px;border-radius:20px;font-size:0.85rem;font-weight:bold;margin-top:8px;}");
            out.println(".details{margin:20px 0;}");
            out.println(".detail-row{display:flex;justify-content:space-between;padding:10px 0;border-bottom:1px solid #1f2937;}");
            out.println(".detail-label{font-weight:bold;color:#9ca3af;font-size:0.9rem;}");
            out.println(".detail-value{color:#e5e5e5;font-size:0.9rem;text-align:right;max-width:60%;}");
            out.println(".qr-section{text-align:center;margin:28px 0 10px;}");
            out.println(".qr-section p{color:#9ca3af;font-size:0.85rem;margin-top:10px;}");
            out.println("#bookingQrCode{display:inline-block;min-width:220px;min-height:220px;padding:8px;background:#fff;border:4px solid #00ff66;border-radius:10px;}");
            out.println("#bookingQrCode img,#bookingQrCode canvas{display:block;width:220px;height:220px;}");
            out.println(".qr-error{color:#ff8888;}");
            out.println(".receipt-link{display:inline-block;margin-top:12px;color:#00ff66;text-decoration:none;}");
            out.println(".footer{text-align:center;margin-top:24px;color:#6b7280;font-size:0.78rem;border-top:1px solid #1f2937;padding-top:16px;}");
            out.println("@media print{body{background:white;} .receipt{box-shadow:none;background:white;color:#111;} .detail-label{color:#555;} .detail-value{color:#111;} .header h1{color:#00aa44;} .footer{color:#888;}}");
            out.println("</style>");
            out.println("</head>");
            out.println("<body>");
            out.println("<div class='receipt'>");

            // Header
            out.println("<div class='header'>");
            out.println("<h1>&#9889; BookMyCNG</h1>");
            out.println("<p>CNG Slot Booking Receipt</p>");
            out.println("<span class='badge'>&#10003; " + status + "</span>");
            out.println("</div>");

            // Booking details
            out.println("<div class='details'>");
            out.println("<div class='detail-row'><span class='detail-label'>Receipt Number</span><span class='detail-value'>#" + bookingId + "</span></div>");
            out.println("<div class='detail-row'><span class='detail-label'>Station</span><span class='detail-value'>" + pumpName + "</span></div>");
            out.println("<div class='detail-row'><span class='detail-label'>Address</span><span class='detail-value'>" + address + (city.isEmpty() ? "" : ", " + city) + "</span></div>");
            out.println("<div class='detail-row'><span class='detail-label'>Booking Date</span><span class='detail-value'>" + bookDate + "</span></div>");
            out.println("<div class='detail-row'><span class='detail-label'>Time Slot</span><span class='detail-value'>" + slotTime + "</span></div>");
            out.println("<div class='detail-row'><span class='detail-label'>Vehicle Type</span><span class='detail-value'>" + vehType + "</span></div>");
            out.println("<div class='detail-row'><span class='detail-label'>Vehicle Number</span><span class='detail-value'>" + vehNum + "</span></div>");
            out.println("<div class='detail-row'><span class='detail-label'>Customer Name</span><span class='detail-value'>" + custName + "</span></div>");
            out.println("<div class='detail-row'><span class='detail-label'>Phone</span><span class='detail-value'>" + custPhone + "</span></div>");
            out.println("<div class='detail-row'><span class='detail-label'>Email</span><span class='detail-value'>" + custEmail + "</span></div>");
            out.println("<div class='detail-row'><span class='detail-label'>Booking Created</span><span class='detail-value'>" + createdAt + "</span></div>");
            out.println("</div>");

            // Booking verification QR section
            out.println("<div class='qr-section'>");
            out.println("<h2>Booking Verification</h2>");
            out.println("<div id='bookingQrCode' role='img' aria-label='QR code for booking " + bookingId
                    + "' data-qr='" + escapeHtmlAttribute(qrData) + "'></div>");
            out.println("<p id='qrStatus' class='qr-error' role='status' aria-live='polite'></p>");
            out.println("<p>Scan this QR code at the station to verify your booking</p>");
            out.println("</div>");

            // Footer
            out.println("<div class='footer'>");
            out.println("<p>Thank you for using BookMyCNG! Please show this receipt at the CNG station.</p>");
            out.println("<p>Generated on: " + new SimpleDateFormat("dd MMM yyyy, hh:mm a").format(new Date()) + "</p>");
            out.println("<a class='receipt-link' href='" + request.getContextPath() + "/UserOrders'>Back to My Bookings</a>");
            out.println("</div>");

            out.println("</div>");
            out.println("<script src='" + request.getContextPath() + "/js/qrcode.min.js'></script>");
            out.println("<script>");
            out.println("(function(){");
            out.println("var target=document.getElementById('bookingQrCode');");
            out.println("if(typeof QRCode==='undefined'){document.getElementById('qrStatus').textContent='QR code could not load. Check your internet connection and reopen this receipt.';return;}");
            out.println("new QRCode(target,{text:target.getAttribute('data-qr'),width:220,height:220,colorDark:'#000000',colorLight:'#ffffff',correctLevel:QRCode.CorrectLevel.M});");
            out.println("})();");
            out.println("</script>");
            out.println("</body>");
            out.println("</html>");

            rs.close();
            pst.close();

        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error generating receipt: " + e.getMessage());
        } finally {
            try { if (con != null) con.close(); } catch (Exception e) { e.printStackTrace(); }
        }
    }
}
