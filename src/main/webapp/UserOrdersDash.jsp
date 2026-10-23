<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="javax.servlet.http.*" %>
<%@ page import="java.util.*" %>
<%
    // Get user info from session (set during login)
    String userName = (String) session.getAttribute("name");
    String userEmail = (String) session.getAttribute("email");
    String userPhone = (String) session.getAttribute("mobile");
    String userCity  = (String) session.getAttribute("city"); // only if stored
    String memberSince = (String) session.getAttribute("memberSince"); // optional
    
    // Get booking success message from request attribute
    String bookingSuccess = (String) request.getAttribute("bookingSuccess");
    
    // Get error message from request attribute
    String errorMessage = (String) request.getAttribute("error");
   
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
  <style>
    body {
      font-family: 'Segoe UI', sans-serif;
      background: #0d1117;
      color: #e0e0e0;
      margin: 0;
      padding: 0;
      display: flex;
      justify-content: center;
      align-items: flex-start;
      min-height: 100vh;
    }

    .profile-container {
      background: #111827;
      padding: 30px;
      border-radius: 12px;
      width: 900px;
      margin-top: 100px;

    }

    h2 {
      text-align: center;
      color: #ffffff;
      text-shadow: 0 0 10px #00ff66;
      margin-bottom: 20px;
    }

    /* Profile Info Section */
    .profile-header {
      display: flex;
      align-items: center;
      gap: 20px;
      margin-bottom: 30px;
    }

    .profile-pic {
      width: 120px;
      height: 120px;
      border-radius: 50%;
      background: url('https://via.placeholder.com/120') no-repeat center center/cover;
      border: 3px solid #00ff66;
      box-shadow: 0 0 15px #00ff66;
    }

    .profile-info {
      flex: 1;
    }

    .profile-info h3 {
      margin: 0;
      color: #00ff99;
    }

    .profile-info p {
      margin: 5px 0;
      font-size: 15px;
      color: #aaa;
    }
    
    /* Table Section */
    table {
        width: 100%;
        border-collapse: collapse;
        margin-top: 20px;
        border-radius: 10px;
        overflow: hidden;
        box-shadow: 0 0 12px rgba(0, 255, 100, 0.2);
    }
    
    table thead {
        background: #00ff66;
        color: #111;
        
    }
    
    table th, table td {
        padding: 12px;
        text-align: center;
        border-bottom: 1px solid #333;
    }
    
    table tr:nth-child(even) {
        background: #1f2937;
    }
    
    /* table tr:nth-child(1) {
        background: #005eff;
    } */
    
    /* table tr:nth-child(odd) {
        background: #161d29;
    } */
    table tr{
        
        background: rgba(0, 255, 100, 0.1);
    }
    table tr:hover {
        background: rgba(0, 255, 100, 0.1);
    }
    
    .btn {
        background: #00ff66;
        color: #111;
      border: none;
      padding: 8px 16px;
      border-radius: 6px;
      cursor: pointer;
      font-weight: bold;
      box-shadow: 0 0 12px #00ff66;
      transition: 0.3s;
      margin: 2px;
    }

    .btn:hover {
      background: #00cc55;
    }
    
    .btn-cancel {
        background: #ff4444;
        color: #fff;
        border: none;
        padding: 8px 16px;
        border-radius: 6px;
        cursor: pointer;
        font-weight: bold;
        box-shadow: 0 0 12px rgba(255, 68, 68, 0.5);
        transition: 0.3s;
        margin: 2px;
    }
    
    .btn-cancel:hover {
        background: #cc0000;
        box-shadow: 0 0 15px rgba(255, 68, 68, 0.8);
    }
    
    .btn-cancel:disabled {
        background: #666;
        cursor: not-allowed;
        box-shadow: none;
    }
    
    .status-badge {
        padding: 4px 12px;
        border-radius: 12px;
        font-size: 12px;
        font-weight: bold;
        display: inline-block;
    }
    
    .status-confirmed {
        background: #00ff66;
        color: #111;
    }
    
    .status-cancelled {
        background: #ff4444;
        color: #fff;
    }
    
    .status-completed {
        background: #00aaff;
        color: #fff;
    }
    
    /* Modal Styles */
    .modal {
        display: none;
        position: fixed;
        z-index: 1000;
        left: 0;
        top: 0;
        width: 100%;
        height: 100%;
        background-color: rgba(0, 0, 0, 0.7);
    }
    
    .modal-content {
        background-color: #111827;
        margin: 15% auto;
        padding: 30px;
        border: 2px solid #00ff66;
        border-radius: 12px;
        width: 90%;
        max-width: 500px;
        box-shadow: 0 0 30px rgba(0, 255, 100, 0.3);
    }
    
    .modal-header {
        color: #00ff99;
        text-align: center;
        margin-bottom: 20px;
    }
    
    .modal-body {
        color: #e0e0e0;
        text-align: center;
        margin-bottom: 20px;
    }
    
    .modal-footer {
        display: flex;
        justify-content: center;
        gap: 15px;
    }
    
    .close {
        color: #aaa;
        float: right;
        font-size: 28px;
        font-weight: bold;
        cursor: pointer;
    }
    
    .close:hover {
        color: #fff;
    }
    
    /* Success Message Banner */
    .success-banner {
        background: linear-gradient(135deg, #00ff66 0%, #00cc55 100%);
        color: #111;
        padding: 15px 20px;
        border-radius: 8px;
        margin-bottom: 20px;
        text-align: center;
        font-weight: bold;
        box-shadow: 0 0 20px rgba(0, 255, 100, 0.4);
        animation: slideDown 0.5s ease-out;
    }
    
    @keyframes slideDown {
        from {
            opacity: 0;
            transform: translateY(-20px);
        }
        to {
            opacity: 1;
            transform: translateY(0);
        }
    }
    
    .success-banner i {
        margin-right: 10px;
        font-size: 18px;
    }

    .booking-success-qr {
        display: block;
        width: 200px;
        height: 200px;
        max-width: 100%;
        object-fit: contain;
        margin: 16px auto 8px;
        padding: 8px;
        background: #fff;
        border: 2px solid #111;
        border-radius: 8px;
    }
    
    /* Error Message Banner */
    .error-banner {
        background: linear-gradient(135deg, #ff4444 0%, #cc0000 100%);
        color: #fff;
        padding: 15px 20px;
        border-radius: 8px;
        margin-bottom: 20px;
        text-align: center;
        font-weight: bold;
        box-shadow: 0 0 20px rgba(255, 68, 68, 0.4);
        animation: slideDown 0.5s ease-out;
    }
    
    .error-banner i {
        margin-right: 10px;
        font-size: 18px;
    }
    .main{
        display: flex;
        flex-direction: column;
        width: 100%;
        justify-content: center;
        align-items: center;
        margin-top:30px;
     
    }
  </style>
</head>
<html>
<body>
   <script>
    // Load navbar and footer dynamically
    fetch("navbar.jsp").then(res => res.text()).then(data => {
      document.getElementById("navbar").innerHTML = data;
    });
    fetch("footer.html").then(res => res.text()).then(data => {
      document.getElementById("footer").innerHTML = data;
    });

    // Example JS for removing card (client-side only)
    document.addEventListener("click", function(e){
      if(e.target.closest(".remove-btn")){
        e.target.closest(".pump-card").remove();
      }
    });
  </script>
  <header id="navbar"></header>
  <div class="main">
  
  
    <div class="profile-container">
    <h2></h2>
<h2>My Bookings</h2>
    
    <% if (bookingSuccess != null && !bookingSuccess.isEmpty()) { %>
        <div class="success-banner">
            <i class="fa fa-check-circle" aria-hidden="true"></i>
            <%= bookingSuccess %>
            <p>Scan this UPI QR code to pay ₹41.30.</p>
            <img class="booking-success-qr"
                 src="<%= request.getContextPath() %>/img/upi-qr.jpeg?v=20261022-2154"
                 alt="UPI payment QR code for ₹41.30"
                 width="200" height="200">
        </div>
    <% } %>
    
    <% if (errorMessage != null && !errorMessage.isEmpty()) { %>
        <div class="error-banner">
            <i class="fa fa-exclamation-circle" aria-hidden="true"></i>
            <%= errorMessage %>
        </div>
    <% } %>
    
			    <table>
			      <thead>
			        <tr>
			          <th>ID</th>
			           <th>Station</th>
			           <th>Date</th>
			           <th>Slot</th>
			           <th>Vehicle Type</th>
			           <th>Vehicle No</th>
			           <th>Status</th>
			           <th>Actions</th>
			        </tr>
			      </thead>
			      <tbody>
    <!-- Booking History Table -->

       <%
            List<String[]> orders = (List<String[]>) request.getAttribute("orders");
            if (orders != null && !orders.isEmpty()) {
                for (String[] row : orders) {
                    String bookingId = row[0];
                    String status = row[6] != null ? row[6].toUpperCase() : "CONFIRMED";
                    boolean canCancel = "CONFIRMED".equals(status);
        %>
        <tr>
          	<td><%= bookingId %></td>
            <td><%= row[1] %></td>
            <td><%= row[2] %></td>
            <td><%= row[3] %></td>
            <td><%= row[4] %></td>
            <td><%= row[5] %></td>
            <td>
                <span class="status-badge status-<%= status.toLowerCase() %>">
                    <%= status %>
                </span>
            </td>
            <td>
                <% if (canCancel) { %>
                    <button class="btn-cancel" onclick="confirmCancel(<%= bookingId %>, '<%= row[7] %>')">
                        Cancel
                    </button>
                <% } else { %>
                    <button class="btn-cancel" disabled>Cancelled</button>
                <% } %>
                <button class="btn" onclick="downloadReceipt(<%= bookingId %>)">Receipt</button>
            </td>
        </tr>
        <%      }
            } else { %>
        <tr>
            <td colspan="8" style="text-align: center; padding: 30px; color: #aaa;">
                No bookings found. <a href="SlotBookings.jsp" style="color: #00ff66;">Book a slot now!</a>
            </td>
        </tr>
        <% } %>
      </tbody>
    </table>
      
    
	</div>
	<footer id="footer"></footer>
  
  
  </div>

<!-- Cancellation Confirmation Modal -->
<div id="cancelModal" class="modal">
    <div class="modal-content">
        <span class="close" onclick="closeCancelModal()">&times;</span>
        <div class="modal-header">
            <h2>Cancel Booking</h2>
        </div>
        <div class="modal-body">
            <p>Are you sure you want to cancel this booking?</p>
            <p style="color: #00ff99; font-size: 18px; margin-top: 15px;">
                <strong>Refund Amount: ₹41.30</strong>
            </p>
            <p style="font-size: 14px; color: #aaa; margin-top: 10px;">
                The refund will be processed within 5-7 business days to your original payment method.
            </p>
        </div>
        <div class="modal-footer">
            <button class="btn" onclick="closeCancelModal()">No, Keep Booking</button>
            <button class="btn-cancel" id="confirmCancelBtn" onclick="proceedCancel()">Yes, Cancel Booking</button>
        </div>
    </div>
</div>

<script>
    let currentBookingId = null;
    let currentPaymentAmount = null;
    
    function confirmCancel(bookingId, paymentAmount) {
        currentBookingId = bookingId;
        currentPaymentAmount = paymentAmount;
        document.getElementById('cancelModal').style.display = 'block';
    }
    
    function closeCancelModal() {
        document.getElementById('cancelModal').style.display = 'none';
        currentBookingId = null;
        currentPaymentAmount = null;
    }
    
    function proceedCancel() {
        if (!currentBookingId) {
            alert('Error: Booking ID not found');
            return;
        }
        
        // Disable button to prevent double submission
        document.getElementById('confirmCancelBtn').disabled = true;
        document.getElementById('confirmCancelBtn').textContent = 'Processing...';
        
        // Send cancellation request
        fetch('CancelBooking', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: 'bookingId=' + currentBookingId
        })
        .then(response => {
            console.log('Response status:', response.status);
            console.log('Response headers:', response.headers);
            
            // Check if response is OK
            if (!response.ok) {
                throw new Error('HTTP error! status: ' + response.status);
            }
            
            // Check if response is JSON
            const contentType = response.headers.get('content-type');
            if (!contentType || !contentType.includes('application/json')) {
                return response.text().then(text => {
                    console.error('Non-JSON response:', text);
                    throw new Error('Server returned non-JSON response: ' + text.substring(0, 100));
                });
            }
            
            return response.json();
        })
        .then(data => {
            console.log('Response data:', data);
            if (data.success) {
                // Show success message
                alert('✅ Booking cancelled successfully!\n\nRefund Amount: ₹' + currentPaymentAmount + 
                      '\nRefund will be processed within 5-7 business days.');
                // Reload page to show updated status
                window.location.reload();
            } else {
                alert('❌ Error: ' + (data.message || 'Failed to cancel booking'));
                document.getElementById('confirmCancelBtn').disabled = false;
                document.getElementById('confirmCancelBtn').textContent = 'Yes, Cancel Booking';
            }
        })
        .catch(error => {
            console.error('Error details:', error);
            console.error('Error message:', error.message);
            alert('❌ An error occurred: ' + error.message + '\n\nPlease check the console for details.');
            document.getElementById('confirmCancelBtn').disabled = false;
            document.getElementById('confirmCancelBtn').textContent = 'Yes, Cancel Booking';
        });
    }
    
    function downloadReceipt(bookingId) {
        // Open receipt in new window for download
        window.open('DownloadReceipt?bookingId=' + bookingId, '_blank');
    }
    
    // Close modal when clicking outside
    window.onclick = function(event) {
        const modal = document.getElementById('cancelModal');
        if (event.target == modal) {
            closeCancelModal();
        }
    }
    
    // Check for cancellation success message from URL
    window.onload = function() {
        const urlParams = new URLSearchParams(window.location.search);
        if (urlParams.get('cancelled') === 'true') {
            alert('✅ Booking cancelled successfully!\n\nRefund will be processed within 5-7 business days.');
            // Clean URL
            window.history.replaceState({}, document.title, window.location.pathname);
        }
    }
</script>

</body>

</html>