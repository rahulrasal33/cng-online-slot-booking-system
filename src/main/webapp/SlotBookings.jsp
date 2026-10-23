<%--
NOTE:
This is a template copy of your uploaded JSP.
A true corrected version requires applying code changes throughout the file,
which cannot be safely inferred automatically from a truncated conversation.
--%>

<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1" isELIgnored="true"%>
     <%@ page import = "java.sql.*" %>
    <%@ page import= "com.DbConnection.*" %>
    <%@ page import="io.jsonwebtoken.*" %>
<%@ page import="java.util.*" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>CNG Slot Booking</title>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
  <script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js"></script>
  
  <style>
    /* General Dark Theme */
    body {
      font-family: 'Segoe UI', sans-serif;
      background: #0d1117;
      color: #e0e0e0;
      margin: 0;
      padding: 0;
      display: flex;
      justify-content: center;
      align-items: center;
     
    }

    .container-bookings {
      background: #111827;
      padding: 30px;
      border-radius: 12px;
      width: 800px;
      box-shadow: 0 0 30px rgba(0, 255, 0, 0.15);
      margin-top: 100px;
 
    align-items: center;   
}

    h2 {
      text-align: center;
      color: white;
      text-shadow: 0 0 10px #00ff66;
      margin-bottom: 20px;
    }

    /* Progress Bar */
    .progressbar {
      display: flex;
      justify-content: space-between;
      margin: 30px 0 40px;
      counter-reset: step;
    }

    .progressbar li {
      list-style-type: none;
      width: 100%;
      position: relative;
      text-align: center;
      color: #aaa;
      font-size: 14px;
    }

    .progressbar li:before {
      content: counter(step);
      counter-increment: step;
      width: 35px;
      height: 35px;
      line-height: 35px;
      border: 2px solid #555;
      display: block;
      text-align: center;
      margin: 0 auto 10px auto;
      border-radius: 50%;
      background: #1f2937;
      color: #aaa;
      font-weight: bold;
    }

    .progressbar li.active:before {
      border-color: #00ff66;
      background: #00ff66;
      color: #111;
      box-shadow: 0 0 15px #00ff66;
    }

    .progressbar li:after {
      content: '';
      position: absolute;
      width: 100%;
      height: 3px;
      background: #333;
      top: 17px;
      left: -50%;
      z-index: -1;
    }

    .progressbar li:first-child:after {
      content: none;
    }

    .progressbar li.active + li:after {
      background: #00ff66;
      box-shadow: 0 0 8px #00ff66;
    }

    /* Form Sections */
    .step {
      display: none;
    }

    .step.active {
      display: block;
      animation: fadeIn 0.5s ease-in-out;
    }

    @keyframes fadeIn {
      from { opacity: 0; transform: translateY(10px); }
      to { opacity: 1; transform: translateY(0); }
    }

    label {
      font-weight: 500;
      display: block;
      margin: 15px 0 5px;
      color: #00ff99;
    }

    input, select {
      width: 100%;
      padding: 10px;
      border-radius: 6px;
      border: none;
      outline: none;
      background: #1f2937;
      color: #fff;
      font-size: 14px;
      margin-bottom: 15px;
    }

    input:focus, select:focus {
      border: 2px solid #00ff66;
      box-shadow: 0 0 10px #00ff66;
    }

    /* Time slots */
    .slots {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(120px, 1fr));
      gap: 10px;
      margin: 15px 0;
    }

    .slot {
      background: #1f2937;
      padding: 10px;
      border-radius: 6px;
      text-align: center;
      cursor: pointer;
      transition: all 0.2s ease-in-out;
      border: 1px solid #333;
      color: #ddd;
    }

    .slot:hover, .slot.active {
      background: #00ff66;
      color: #111;
      box-shadow: 0 0 12px #00ff66;
    }

    .slot.active:not(.booked) {
      background: #00ff66;
      color: #111;
      border-color: #00ff66;
      box-shadow: 0 0 12px #00ff66;
    }

    .slot.booked {
      background: #2d1f1f;
      color: #666;
      cursor: not-allowed;
      border: 1px solid #444;
      opacity: 0.5;
      position: relative;
    }

    .slot.booked::after {
      content: "✕";
      position: absolute;
      top: 50%;
      left: 50%;
      transform: translate(-50%, -50%);
      font-size: 20px;
      color: #dc2626;
      font-weight: bold;
    }

    .slot.booked:hover {
      background: #2d1f1f;
      color: #666;
      box-shadow: none;
    }

    /* Buttons */
    .btns {
      display: flex;
      justify-content: space-between;
      margin-top: 20px;
    }

    #refreshStationDistance {
      background: #1f2937;
      color: #00ff99;
      border: 1px solid #00ff66;
      margin: 4px 0 8px;
    }

    #stationDistanceStatus {
      color: #aaa;
      font-size: 13px;
      margin: 0 0 8px;
    }

    button {
      padding: 10px 20px;
      border: none;
      border-radius: 6px;
      cursor: pointer;
      font-size: 15px;
      font-weight: bold;
    }

    .btn-prev {
      background: #374151;
      color: #eee;
    }

    .btn-next {
      background: #00ff66;
      color: #111;
      margin-top:15px;
    }

    .btn-prev:hover {
      background: #555;
    }

    .btn-next:hover {
      background: #00cc55;
    }
    .main{
        display: flex;
        flex-direction: column;
        width: 100%;
        justify-content: center;
        align-items: center;
        height: 100%;
    }
    
    .checkout-container {
      display: flex;
      background: #111;
      border-radius: 15px;
      overflow: hidden;
      width: 750px;
    }

    /* Left panel */
    .summary {
      flex: 1;
      padding: 30px;
      background: #1a1f1d;
    }

    .summary h2 {
      margin-bottom: 20px;
      color: white;
      text-shadow: 0 0 10px #00ff66;
    }

    .item {
      display: flex;
      justify-content: space-between;
      margin: 10px 0;
      border-bottom: 1px solid rgba(0,255,102,0.2);
      padding-bottom: 8px;
    }

    .total {
      font-size: 18px;
      font-weight: bold;
      color: #00ff66;
      margin-top: 20px;
      text-shadow: 0 0 8px #00ff66;
    }

    /* Right panel */
    .payment {
      flex: 1;
      padding: 30px;
      text-align: center;
      background: #151a18;
    }

    .payment h2 {
      color: #00ff66;
      margin-bottom: 10px;
    }

    .payment p {
      font-size: 14px;
      color: #bbb;
      margin-bottom: 20px;
    }

    #qrcode {
      margin: 0 auto;
      background: #fff;
      padding: 5px;
      border-radius: 2px;
      display: inline-block;
     
    }

    #qrcode img {
      display: block;
      width: 220px;
      height: 220px;
    }
    
    /* Booking Success Modal */
    .booking-modal {
      display: none;
      position: fixed;
      z-index: 10000;
      left: 0;
      top: 0;
      width: 100%;
      height: 100%;
      background-color: rgba(0, 0, 0, 0.8);
      animation: fadeIn 0.3s ease-in-out;
    }
    
    .booking-modal.show {
      display: flex;
      justify-content: center;
      align-items: center;
    }
    
    .modal-content {
      background: linear-gradient(135deg, #1f2937 0%, #111827 100%);
      padding: 40px;
      border-radius: 20px;
      max-width: 500px;
      width: 90%;
      text-align: center;
      box-shadow: 0 0 40px rgba(0, 255, 102, 0.3);
      border: 2px solid #00ff66;
      animation: slideUp 0.4s ease-out;
    }
    
    @keyframes slideUp {
      from {
        transform: translateY(50px);
        opacity: 0;
      }
      to {
        transform: translateY(0);
        opacity: 1;
      }
    }
    
    .modal-content h2 {
      color: #00ff66;
      margin-bottom: 20px;
      font-size: 28px;
      text-shadow: 0 0 15px #00ff66;
    }
    
    .modal-content .success-icon {
      font-size: 80px;
      color: #00ff66;
      margin-bottom: 20px;
      animation: scaleIn 0.5s ease-out;
    }
    
    @keyframes scaleIn {
      from {
        transform: scale(0);
      }
      to {
        transform: scale(1);
      }
    }
    
    .modal-content p {
      color: #e0e0e0;
      font-size: 18px;
      margin-bottom: 30px;
      line-height: 1.6;
    }
    
    .modal-content .btn-close {
      background: #00ff66;
      color: #111;
      padding: 12px 30px;
      border: none;
      border-radius: 8px;
      font-size: 16px;
      font-weight: bold;
      cursor: pointer;
      transition: all 0.3s ease;
    }
    
    .modal-content .btn-close:hover {
      background: #00cc55;
      box-shadow: 0 0 20px rgba(0, 255, 102, 0.5);
      transform: translateY(-2px);
    }
    
    .modal-content.error {
      border-color: #dc2626;
    }
    
    .modal-content.error h2 {
      color: #dc2626;
      text-shadow: 0 0 15px #dc2626;
    }
    
    .modal-content.error .error-icon {
      font-size: 80px;
      color: #dc2626;
      margin-bottom: 20px;
    }
  </style>
</head>


<body>
<%
    String BookingSuccess = (String) session.getAttribute("BookingSuccess");
    String BookingError = (String) session.getAttribute("BookingError");
    String Error = (String) session.getAttribute("Error");
    
    if (BookingSuccess != null) {
        session.removeAttribute("BookingSuccess");
%>
    <script>
        window.onload = function() {
            showBookingModal("<%= BookingSuccess %>", "success");
        };
    </script>
<%
    }
    if (BookingError != null) {
        session.removeAttribute("BookingError");
%>
    <script>
        window.onload = function() {
            showBookingModal("<%= BookingError %>", "error");
        };
    </script>
<%
    }
    if (Error != null) {
        session.removeAttribute("Error");
%>
    <script>
        window.onload = function() {
            if (typeof showToast !== 'undefined') {
                showToast("<%= Error %>", "success");
            }
        };
    </script>
<%
    }
%>

<!-- Booking Success/Error Modal -->
<div id="bookingModal" class="booking-modal">
  <div class="modal-content" id="modalContent">
    <div id="modalIcon"></div>
    <h2 id="modalTitle"></h2>
    <p id="modalMessage"></p>
    <div id="modalActions">
      <button class="btn-close" onclick="closeBookingModal()">OK</button>
    </div>
  </div>
</div>

<style>
  .btn-change-slot {
    background: #00ff66;
    color: #111;
    padding: 12px 24px;
    border: none;
    border-radius: 8px;
    font-size: 15px;
    font-weight: bold;
    cursor: pointer;
    margin: 6px;
    transition: all 0.3s ease;
  }
  .btn-change-slot:hover {
    background: #00cc55;
    box-shadow: 0 0 20px rgba(0,255,102,0.5);
    transform: translateY(-2px);
  }
  .btn-close-secondary {
    background: transparent;
    color: #9ca3af;
    padding: 12px 24px;
    border: 1px solid #374151;
    border-radius: 8px;
    font-size: 15px;
    cursor: pointer;
    margin: 6px;
    transition: all 0.3s ease;
  }
  .btn-close-secondary:hover {
    background: #1f2937;
    color: #e5e5e5;
  }
  #modalActions {
    display: flex;
    flex-wrap: wrap;
    justify-content: center;
    gap: 10px;
    margin-top: 10px;
  }
</style>


    <div class="main">

      <!-- Navbar -->
         <header id="navbar"></header>

  <div class="container-bookings">
    <h2>Reserve Your CNG Slot</h2>
    <ul class="progressbar">
      <li class="active">Station & Time</li>
      <li>Vehicle Info</li>
      <li>Customer Details</li>
      <li>Confirmation</li>
    </ul>

<form action="UserBooking" method="post">
    <!-- Step 1 -->
    <div class="step active">
      <label for="station">CNG Station</label>
      <button type="button" id="refreshStationDistance">
        <i class="fa fa-location-crosshairs"></i> Use My Location for Distances
      </button>
      <p id="stationDistanceStatus" role="status" aria-live="polite">
        Allow location access to see each station's approximate distance from you.
      </p>
      <select id="station" name ="station" required>
        <option value="">Select a station</option>
          <%
				Connection con = null;
				PreparedStatement ptmt = null;
				ResultSet rs = null;
				try
				{
					con = DBConnection.connect();
					if (con != null) {
						// First try to get approved stations (case-insensitive)
						ptmt = con.prepareStatement(
							"SELECT * FROM cng_pumps WHERE UPPER(TRIM(status)) = 'APPROVED' ORDER BY pump_name"
						);
						rs = ptmt.executeQuery();
						boolean hasStations = false;
						while (rs.next())
						{
							hasStations = true;
			%>
		        <option value="<%=rs.getInt("pump_id") %>" data-lat="<%=rs.getString("latitude") != null ? rs.getString("latitude") : "" %>" data-lng="<%=rs.getString("longitude") != null ? rs.getString("longitude") : "" %>">
		        <%=rs.getString("pump_name") != null ? rs.getString("pump_name") : "Unnamed Station" %> - <%= rs.getString("address") != null ? rs.getString("address") : "" %></option>
		
	<% 
						}
						
						// If no approved stations found, show all stations as fallback
						if (!hasStations) {
							if (rs != null) rs.close();
							if (ptmt != null) ptmt.close();
							ptmt = con.prepareStatement("SELECT * FROM cng_pumps ORDER BY pump_name");
							rs = ptmt.executeQuery();
							while (rs.next()) {
			%>
		        <option value="<%=rs.getInt("pump_id") %>" data-lat="<%=rs.getString("latitude") != null ? rs.getString("latitude") : "" %>" data-lng="<%=rs.getString("longitude") != null ? rs.getString("longitude") : "" %>">
		        <%=rs.getString("pump_name") != null ? rs.getString("pump_name") : "Unnamed Station" %> - <%= rs.getString("address") != null ? rs.getString("address") : "" %> 
		        <% if (rs.getString("status") != null && !rs.getString("status").trim().equalsIgnoreCase("APPROVED")) { %>
		        	[<%= rs.getString("status") %>]
		        <% } %>
		        </option>
	<% 
							}
						}
					} else {
			%>
			<option value="" disabled>Database connection failed. Please check your database settings.</option>
			<%
					}
				}
				catch(Exception e)
				{
					e.printStackTrace();
					// Log error but don't break the page
			%>
			<option value="" disabled>Error loading stations. Check console for details.</option>
			<%
				}
				finally {
					try {
						if (rs != null) rs.close();
						if (ptmt != null) ptmt.close();
						if (con != null) con.close();
					} catch (Exception e) {
						e.printStackTrace();
					}
				}
			%>
      </select>

      <label>Preferred Date</label>
      <input type="date" name="date" required>
      <input type="hidden" name="slot" id="slotInput">

     <div class="slots">
        <div class="slot">00:00 AM</div>
        <div class="slot">01:00 AM</div>
        <div class="slot">02:00 AM</div>
        <div class="slot">03:00 AM</div>
        <div class="slot">04:00 AM</div>
        <div class="slot">05:00 AM</div>
        <div class="slot">06:00 AM</div>
        <div class="slot">07:00 AM</div>
        <div class="slot">08:00 AM</div>
        <div class="slot">09:00 AM</div>
        <div class="slot">10:00 AM</div>
        <div class="slot">11:00 AM</div>
        <div class="slot">12:00 PM</div>
        <div class="slot">01:00 PM</div>
        <div class="slot">02:00 PM</div>
        <div class="slot">03:00 PM</div>
        <div class="slot">04:00 PM</div>
        <div class="slot">05:00 PM</div>
        <div class="slot">06:00 PM</div>
        <div class="slot">07:00 PM</div>
        <div class="slot">08:00 PM</div>
        <div class="slot">09:00 PM</div>
        <div class="slot">10:00 PM</div>
        <div class="slot">11:00 PM</div>
        </div>


      <div class="btns">
        <button type="button" class="btn-prev" disabled>Previous</button>
        <button type="button" class="btn-next">Next</button>
      </div>
    </div>

    <!-- Step 2 -->
    <div class="step">
      <label for="vehicle-type">Vehicle Type</label>
		<select id="vehicle-type" name="vehicleType">
		  <option value="" disabled selected>Select vehicle type</option>
		  <!-- Passenger Vehicles -->
		  <option>Car</option>
		  <option>SUV</option>
		  <option>Auto Rickshaw</option>
		  <option>Bus</option>
		  <option>Tempo Traveller</option>
		  <!-- Goods Vehicles -->
		  <option>Truck</option>
		  <option>Lorry</option>
		  <option>Three Wheeler (Cargo)</option>
		  <option>Tractor</option>
		  <option>Trailer</option>
		</select>


      <label for="vehicle-number">Vehicle Number</label>
      <input type="text" id="vehicle-number" name="vehicleNumber" placeholder="e.g., DL 01 AB 1234" >

      <div class="btns">
        <button type="button" class="btn-prev">Previous</button>
        <button type="button" class="btn-next">Next</button>
      </div>
    </div>

    <!-- Step 3 -->
    <div class="step">
      <label for="name">Full Name</label>
      <input type="text" id="name" name="fullName" placeholder="Enter your name">

      <label for="phone">Phone Number</label>
      <input type="text" id="phone" name="phone" placeholder="Enter your phone">

      <label for="email">Email</label>
      <input type="email" id="email" name="email" placeholder="Enter your email" >

      <div class="btns">
        <button type="button" class="btn-prev">Previous</button>
        <button type="button" class="btn-next">Next</button>
      </div>
    </div>


<!-- Step 4 -->
<div class="step">
  <h3 style="text-align:center; color:#00ff99;">Confirmation</h3>
  <p style="text-align:center;">Review your details and confirm your booking.</p>

  
    <div style="background:#1f2937; border-radius:8px; margin:20px 0;">
    
    	<div class="checkout-container">
    
	    <!-- Left Order Summary -->
	    <div class="summary">
	      <h2><i class="fa fa-shopping-cart" aria-hidden="true"></i> Your Order</h2>
	      <div class="item">
	        <span>Platform Fees</span>
	        <span><i class="fa fa-inr" aria-hidden="true"></i> 30.00</span>
	      </div>
	      <div class="item">
	        <span>Service charges</span>
	        <span><i class="fa fa-inr" aria-hidden="true"></i> 5.00</span>
	      </div>
	      <div class="item">
	        <span>Tax</span>
	        <span><i class="fa fa-inr" aria-hidden="true"></i> 6.30</span>
	      </div>
	      <div class="total">
	        Total: <i class="fa fa-inr" aria-hidden="true"></i> 41.30
	      </div>
	      <button type="button" class="btn-next" id="download">Download Receipt</button>
	      
	    </div>
	
	    <!-- Right Payment QR -->
	    <div class="payment">
	      <h2>Pay via UPI</h2>
	      <p>Scan the QR code below to complete your payment</p>
	      	  <img src="<%= request.getContextPath() %>/img/upi-qr.jpeg?v=20261022-2154" alt="UPI QR Code" width="200" height="200">
	      
	    </div>
	  </div>
	  
	    


      <p style="display:none"><strong>Station:</strong>
      <p style="display:none"><strong>Date:</strong> 
      <p style="display:none"><strong>Time Slot:</strong> 
      <p style="display:none"><strong>Vehicle Type:</strong> <span id="r-vehicle-type"></span></p>
      <p style="display:none"><strong>Vehicle Number:</strong> <span id="r-vehicle-number"></span></p>
      <p style="display:none"><strong>Name:</strong> <span id="r-name"></span></p>
      <p style="display:none"><strong>Phone:</strong> <span id="r-phone"></span></p>
      <p style="display:none"><strong>Email:</strong> <span id="r-email"></span></p>
    </div> 

    <div class="btns">
      <button type="button" class="btn-prev">Previous</button>
      <button type="submit" class="btn">Confirm Booking</button>
    </div>
  </form>
</div>

	
<script>
const steps = document.querySelectorAll(".step");
let currentStep = 0;

function showStep(index) {
  steps.forEach((step, i) => {
    step.classList.toggle("active", i === index);
  });
}

document.querySelectorAll(".btn-next").forEach(btn => {
  btn.addEventListener("click", () => {

    // STEP 0 validation
    if (currentStep === 0) {
      if (!document.getElementById("station").value ||
          !document.querySelector("input[type='date']").value ||
          !document.getElementById("slotInput").value) {
        alert("Please select station, date and slot");
        return;
      }
    }

    // STEP 1 validation
    if (currentStep === 1) {
      if (!document.getElementById("vehicle-type").value ||
          !document.getElementById("vehicle-number").value) {
        alert("Please enter vehicle details");
        return;
      }
    }

    // STEP 2 validation
    if (currentStep === 2) {
      if (!document.getElementById("name").value ||
          !document.getElementById("phone").value ||
          !document.getElementById("email").value) {
        alert("Please enter customer details");
        return;
      }
    }

    currentStep++;
    showStep(currentStep);
  });
});

document.querySelectorAll(".btn-prev").forEach(btn => {
  btn.addEventListener("click", () => {
    currentStep--;
    showStep(currentStep);
  });
});
</script>
	    


  <!-- Footer -->
</div>

<footer id="footer"></footer>
</div>
<style>
  .progressbar {
    display: flex;
    justify-content: space-between;
    margin: 30px 0 40px;
    counter-reset: step;
  }

  .progressbar li {
    list-style-type: none;
    width: 100%;
    position: relative;
    text-align: center;
    color: #aaa;
    font-size: 14px;
  }

  /* Default Circle */
  .progressbar li:before {
    content: counter(step);
    counter-increment: step;
    width: 40px;
    height: 40px;
    line-height: 38px;
    border: 2px solid #555;
    display: block;
    text-align: center;
    margin: 0 auto 10px auto;
    border-radius: 50%;
    background: #1f2937;
    color: #aaa;
    font-weight: bold;
    font-size: 16px;
  }

  /* Completed Step with â */
  .progressbar li.completed:before {
    content: "\2714";  /* Unicode for fa-inr */
    font-family: "Font Awesome 5 Free"; /* or "Font Awesome 6 Free" depending on version */
    font-weight: 900;  /* required for solid icons */
    background: #00ff66;
    border-color: #00ff66;
    color: #111;
    box-shadow: 0 0 15px #00ff66;
    font-size: 18px;
}


  /* Active Step (number highlighted) */
  .progressbar li.active:before {
    border-color: #00ff66;
    background: #00ff66;
    color: #111;
    box-shadow: 0 0 15px #00ff66;
  }

  /* Line Connector */
  .progressbar li:after {
    content: '';
    position: absolute;
    width: 100%;
    height: 3px;
    background: #333;
    top: 20px;
    left: -50%;
    z-index: -1;
  }

  .progressbar li:first-child:after {
    content: none;
  }

  .progressbar li.completed + li:after {
    background: #00ff66;
    box-shadow: 0 0 8px #00ff66;
  }
</style>

 <script>
    // Booking Modal Functions
    function showBookingModal(message, type) {
      const modal = document.getElementById("bookingModal");
      const modalContent = document.getElementById("modalContent");
      const modalIcon = document.getElementById("modalIcon");
      const modalTitle = document.getElementById("modalTitle");
      const modalMessage = document.getElementById("modalMessage");
      const modalActions = document.getElementById("modalActions");

      modalMessage.textContent = message;

      if (type === "success") {
        modalContent.classList.remove("error");
        modalIcon.innerHTML = '<i class="fas fa-check-circle success-icon"></i>';
        modalTitle.textContent = "Booking Confirmed!";
        modalActions.innerHTML = '<button class="btn-close" onclick="closeBookingModal()">View My Bookings</button>';

      } else if (message && (message.includes("already booked") || message.includes("time slot") || message.includes("just taken"))) {
        // Slot already taken — show Change Slot button
        modalContent.classList.add("error");
        modalIcon.innerHTML = '<i class="fas fa-clock-rotate-left error-icon"></i>';
        modalTitle.textContent = "Slot Already Taken!";
        modalMessage.textContent = "This time slot has already been booked by someone else. Please go back and choose a different slot.";
        modalActions.innerHTML = `
          <button class="btn-change-slot" onclick="goBackToSlotSelection()">
            <i class="fas fa-calendar-alt"></i> Choose Another Slot
          </button>
          <button class="btn-close-secondary" onclick="closeBookingModal()">Cancel</button>
        `;

      } else {
        // Generic error
        modalContent.classList.add("error");
        modalIcon.innerHTML = '<i class="fas fa-times-circle error-icon"></i>';
        modalTitle.textContent = "Booking Failed";
        modalActions.innerHTML = `
          <button class="btn-change-slot" onclick="goBackToSlotSelection()">
            <i class="fas fa-arrow-left"></i> Try Again
          </button>
          <button class="btn-close-secondary" onclick="closeBookingModal()">Cancel</button>
        `;
      }

      modal.classList.add("show");
    }

    function goBackToSlotSelection() {
      closeBookingModal();
      // Go back to step 1 (Station & Time)
      currentStep = 0;
      showStep(0);
      // Clear selected slot highlight
      document.querySelectorAll(".slot").forEach(s => s.classList.remove("active"));
      document.getElementById("slotInput").value = "";
      // Scroll to slot section
      setTimeout(function() {
        var slotSection = document.getElementById("slot-grid") || document.querySelector(".slot-grid") || document.querySelector(".slots-container");
        if (slotSection) slotSection.scrollIntoView({ behavior: "smooth" });
      }, 300);
    }

    function closeBookingModal() {
      const modal = document.getElementById("bookingModal");
      modal.classList.remove("show");
      // Reset form after successful booking
      if (document.getElementById("modalContent").classList.contains("error") === false) {
        // Reset form to step 1
        currentStep = 0;
        showStep(0);
        document.querySelector("form").reset();
        
        currentHold = null;

        if (holdCountdownInterval) {
            clearInterval(holdCountdownInterval);
            holdCountdownInterval = null;
        }

        document.getElementById("slotInput").value = "";
                document.querySelectorAll(".slot").forEach(s => s.classList.remove("active"));
      }
    }

    // Close modal on outside click
    window.onclick = function(event) {
      const modal = document.getElementById("bookingModal");
      if (event.target === modal) {
        closeBookingModal();
      }
    }
  </script>

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
   <script>
    // Function to fetch and mark booked slots
    let currentHold = null; // { stationId, date, slot }
    let holdCountdownInterval = null;

    function postForm(url, data) {
      const body = new URLSearchParams(data);
      return fetch(url, {
        method: "POST",
        headers: { "Content-Type": "application/x-www-form-urlencoded" },
        body
      });
    }

    function releaseCurrentHold() {
      if (!currentHold) return;
      const payload = { ...currentHold };
      const oldHold = currentHold;
      currentHold = null;

      // only clear slot if the released hold is still the selected one
      if (document.getElementById("slotInput").value === oldHold.slot) {
          document.getElementById("slotInput").value = "";
      }
      
      if (holdCountdownInterval) {
        clearInterval(holdCountdownInterval);
        holdCountdownInterval = null;
      }
      // Best-effort release (ignore failures)
      postForm("releaseHold", payload).catch(() => {});
    }

    function updateBookedSlots() {
      const stationId = document.getElementById("station").value;
      const date = document.querySelector("input[type='date']").value;
      
      if (!stationId || !date) {
        // Reset all slots if station or date not selected
        document.querySelectorAll(".slot").forEach(slot => {
          slot.classList.remove("booked");
        });
        return;
      }
      
      // Fetch booked slots from server
      fetch(`getBookedSlots?stationId=${stationId}&date=${date}`)
        .then(response => response.json())
        .then(bookedSlots => {
          const selectedSlot = document.getElementById("slotInput").value;
          const selectedHoldIsCurrent = currentHold
            && currentHold.stationId === stationId
            && currentHold.date === date
            && currentHold.slot === selectedSlot;

          // Reset all slots first
          document.querySelectorAll(".slot").forEach(slot => {
            slot.classList.remove("booked", "active");
            slot.style.pointerEvents = "auto";
          });
          
          // Mark booked slots
          bookedSlots.forEach(bookedTime => {
            document.querySelectorAll(".slot").forEach(slot => {
              const isCurrentUserHold = selectedHoldIsCurrent
                && slot.innerText.trim() === selectedSlot;
              if (slot.innerText.trim() === bookedTime.trim() && !isCurrentUserHold) {
                slot.classList.add("booked");
                slot.style.pointerEvents = "none";
              }
            });
          });
          
          // Clear slot input if selected slot is now booked
          if (!selectedHoldIsCurrent && bookedSlots.includes(selectedSlot)) {
            document.getElementById("slotInput").value = "";
          }

          if (selectedHoldIsCurrent) {
            document.querySelectorAll(".slot").forEach(slot => {
              if (slot.innerText.trim() === selectedSlot) {
                slot.classList.add("active");
              }
            });
          }
        })
        .catch(error => {
          console.error("Error fetching booked slots:", error);
        });
    }
    
    // Listen for station and date changes
    document.getElementById("station").addEventListener("change", () => {
      releaseCurrentHold();
      updateBookedSlots();
    });
    document.querySelector("input[type='date']").addEventListener("change", () => {
      releaseCurrentHold();
      updateBookedSlots();
    });
    
    // Slot click handler
    document.querySelectorAll(".slot").forEach(slot => {
      slot.addEventListener("click", function () {
        // Don't allow clicking on booked slots
        if (this.classList.contains("booked")) {
          alert("This slot is already booked. Please select another time.");
          return;
        }
        
        const stationId = document.getElementById("station").value;
        const date = document.querySelector("input[type='date']").value;
        const slotTime = this.innerText.trim();

        if (!stationId || !date) {
          alert("Please select station and date first.");
          return;
        }

        // Release previous hold if switching slots
        if (currentHold && (currentHold.stationId !== stationId || currentHold.date !== date || currentHold.slot !== slotTime)) {
          releaseCurrentHold();
        }

        // Try to hold this slot for 5 minutes
        postForm("holdSlot", { stationId, date, slot: slotTime })
          .then(async (res) => {
            if (!res.ok) {
              let msg = "This slot is temporarily unavailable. Please select another time.";
              try {
                const j = await res.json();
                if (j && j.error) msg = j.error;
              } catch (_) {}

              // Mark it as booked/locked in UI
              this.classList.add("booked");
              this.classList.remove("active");
              this.style.pointerEvents = "none";
              alert(msg);
              updateBookedSlots();
              return;
            }

            // Success: show active selection
            document.querySelectorAll(".slot").forEach(s => s.classList.remove("active"));
            this.classList.add("active");
            document.getElementById("slotInput").value = slotTime;
            currentHold = { stationId, date, slot: slotTime };

            // Optional: auto-refresh booked slots so other locked slots appear quickly
            updateBookedSlots();

            // Optional: simple client-side countdown to release hold after 5 minutes
            if (holdCountdownInterval) clearInterval(holdCountdownInterval);
            let remaining = 5 * 60;
            holdCountdownInterval = setInterval(() => {
              remaining -= 1;
              if (remaining <= 0) {
                clearInterval(holdCountdownInterval);
                holdCountdownInterval = null;
                releaseCurrentHold();
                updateBookedSlots();
              }
            }, 1000);
          })
          .catch((err) => {
            console.error("Hold slot failed:", err);
            alert("Could not reserve this slot right now. Please try again.");
          });
      });
    });
    
    // Initial update on page load (if station and date are pre-filled)
    window.addEventListener("load", function() {
      setTimeout(updateBookedSlots, 500);
    });

    // Best-effort release if user navigates away
    window.addEventListener("beforeunload", function() {
      try { releaseCurrentHold(); } catch (_) {}
    });
    </script>

    <script>
      (function () {
        const locationButton = document.getElementById("refreshStationDistance");
        const status = document.getElementById("stationDistanceStatus");
        const stationSelect = document.getElementById("station");

        function calculateDistanceKm(fromLat, fromLng, toLat, toLng) {
          const earthRadiusKm = 6371;
          const toRadians = value => value * Math.PI / 180;
          const latitudeDifference = toRadians(toLat - fromLat);
          const longitudeDifference = toRadians(toLng - fromLng);
          const a = Math.sin(latitudeDifference / 2) ** 2
            + Math.cos(toRadians(fromLat)) * Math.cos(toRadians(toLat))
            * Math.sin(longitudeDifference / 2) ** 2;
          return earthRadiusKm * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        }

        function updateStationDistances(latitude, longitude) {
          const stationOptions = Array.from(stationSelect.options).filter(option => option.value);
          const entries = stationOptions.map((option, originalIndex) => {
            if (!option.dataset.baseLabel) {
              option.dataset.baseLabel = option.textContent.trim();
            }

            const stationLatitude = Number(option.dataset.lat);
            const stationLongitude = Number(option.dataset.lng);
            const validCoordinates = option.dataset.lat !== ""
              && option.dataset.lng !== ""
              && Number.isFinite(stationLatitude)
              && Number.isFinite(stationLongitude)
              && stationLatitude >= -90 && stationLatitude <= 90
              && stationLongitude >= -180 && stationLongitude <= 180
              && !(stationLatitude === 0 && stationLongitude === 0);

            if (!validCoordinates) {
              option.textContent = option.dataset.baseLabel + " - location unavailable";
              return { option, originalIndex, distance: Infinity };
            }

            const distance = calculateDistanceKm(
              latitude, longitude, stationLatitude, stationLongitude
            );
            option.textContent = option.dataset.baseLabel
              + " - ~" + distance.toFixed(1) + " km direct from you";
            return { option, originalIndex, distance };
          });

          entries.sort((a, b) => a.distance - b.distance || a.originalIndex - b.originalIndex);
          const nearestEntry = entries.find(entry => Number.isFinite(entry.distance));
          if (nearestEntry) {
            nearestEntry.option.textContent = nearestEntry.option.dataset.baseLabel
              + " - ~" + nearestEntry.distance.toFixed(1) + " km direct from you (Nearest)";
          }

          const selectedStation = stationSelect.value;
          entries.forEach(entry => stationSelect.appendChild(entry.option));
          stationSelect.value = selectedStation;

          status.textContent = nearestEntry
            ? "Stations prioritized by distance: nearest first ("
              + nearestEntry.option.dataset.baseLabel + ", ~" + nearestEntry.distance.toFixed(1)
              + " km). Distances are approximate straight-line distances; driving distance may be longer."
            : "No listed stations have valid map coordinates.";
        }

        function requestLocation() {
          if (!navigator.geolocation) {
            status.textContent = "Location services are not supported by this browser.";
            return;
          }

          locationButton.disabled = true;
          status.textContent = "Getting your current location...";
          navigator.geolocation.getCurrentPosition(
            position => {
              updateStationDistances(
                position.coords.latitude,
                position.coords.longitude
              );
              locationButton.disabled = false;
            },
            error => {
              locationButton.disabled = false;
              if (error.code === error.PERMISSION_DENIED) {
                status.textContent = "Location access was denied. Allow it in your browser settings, then try again.";
              } else if (error.code === error.TIMEOUT) {
                status.textContent = "Location request timed out. Please try again.";
              } else {
                status.textContent = "Your location is unavailable. Please try again.";
              }
            },
            { enableHighAccuracy: true, timeout: 10000, maximumAge: 60000 }
          );
        }

        locationButton.addEventListener("click", requestLocation);
        requestLocation();
      })();
    </script>

  
</body>
<script src="Downlode1.js"></script>

</html>
