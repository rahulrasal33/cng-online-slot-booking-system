<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isELIgnored="true" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.DbConnection.*" %>
<%
    // Admin session check
    HttpSession adminSession = request.getSession(false);
    if (adminSession == null || adminSession.getAttribute("AdminLoggedIn") == null) {
        response.sendRedirect("AdminLogin.jsp");
        return;
    }

    Connection con = DBConnection.connect();

    // ── Stats ──────────────────────────────────────────
    int totalUsers = 0, totalPumps = 0, totalBookings = 0, confirmedBookings = 0, cancelledBookings = 0, pendingPumps = 0;
    try {
        ResultSet r;
        r = con.prepareStatement("SELECT COUNT(*) FROM users").executeQuery();
        if (r.next()) totalUsers = r.getInt(1); r.close();

        r = con.prepareStatement("SELECT COUNT(*) FROM cng_pumps").executeQuery();
        if (r.next()) totalPumps = r.getInt(1); r.close();

        r = con.prepareStatement("SELECT COUNT(*) FROM slot_bookings").executeQuery();
        if (r.next()) totalBookings = r.getInt(1); r.close();

        r = con.prepareStatement("SELECT COUNT(*) FROM slot_bookings WHERE status='CONFIRMED'").executeQuery();
        if (r.next()) confirmedBookings = r.getInt(1); r.close();

        r = con.prepareStatement("SELECT COUNT(*) FROM slot_bookings WHERE status='CANCELLED'").executeQuery();
        if (r.next()) cancelledBookings = r.getInt(1); r.close();

        r = con.prepareStatement("SELECT COUNT(*) FROM cng_pumps WHERE status='PENDING'").executeQuery();
        if (r.next()) pendingPumps = r.getInt(1); r.close();
    } catch (Exception e) { e.printStackTrace(); }
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Admin Dashboard - BookMyCNG</title>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
<style>
* { box-sizing: border-box; margin: 0; padding: 0; }
body { background: #0b0f19; color: #e5e5e5; font-family: 'Inter', sans-serif; }

/* Top Nav */
.admin-nav {
  background: #111827; padding: 14px 30px;
  display: flex; justify-content: space-between; align-items: center;
  border-bottom: 2px solid #00ff66; position: sticky; top: 0; z-index: 100;
}
.admin-nav h1 { color: #00ff66; font-size: 1.4rem; }
.admin-nav .nav-right { display: flex; gap: 12px; align-items: center; }
.admin-nav span { color: #9ca3af; font-size: 0.9rem; }
.nav-link { color: #9ca3af; text-decoration: none; font-size: 0.9rem; padding: 6px 10px; border-radius: 6px; transition: all 0.2s; }
.nav-link:hover { color: #00ff66; background: #1f2937; }
.btn-logout { background: #dc2626; color: #fff; border: none; padding: 8px 18px; border-radius: 6px; cursor: pointer; font-weight: bold; text-decoration: none; }
.btn-logout:hover { background: #b91c1c; }

/* Tab Nav */
.tab-nav { background: #111827; display: flex; gap: 0; border-bottom: 1px solid #1f2937; padding: 0 30px; overflow-x: auto; }
.tab-btn { padding: 14px 22px; background: none; border: none; color: #9ca3af; cursor: pointer; font-size: 0.95rem; border-bottom: 3px solid transparent; white-space: nowrap; transition: all 0.2s; }
.tab-btn.active { color: #00ff66; border-bottom-color: #00ff66; }
.tab-btn:hover { color: #e5e5e5; }
.tab-btn i { margin-right: 6px; }

/* Content */
.admin-content { padding: 28px 30px; max-width: 1400px; margin: 0 auto; }
.tab-panel { display: none; }
.tab-panel.active { display: block; }

/* Stats Grid */
.stats-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)); gap: 16px; margin-bottom: 30px; }
.stat-card { background: #111827; border-radius: 12px; padding: 22px; text-align: center; border: 1px solid #1f2937; transition: transform 0.2s; }
.stat-card:hover { transform: translateY(-3px); }
.stat-card .stat-icon { font-size: 2rem; margin-bottom: 10px; }
.stat-card .stat-num { font-size: 2.2rem; font-weight: bold; color: #00ff66; }
.stat-card .stat-label { color: #9ca3af; font-size: 0.85rem; margin-top: 4px; }
.stat-card.red .stat-num { color: #ef4444; }
.stat-card.yellow .stat-num { color: #f59e0b; }
.stat-card.blue .stat-num { color: #3b82f6; }
.stat-card.purple .stat-num { color: #a855f7; }

/* Section Header */
.section-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 18px; }
.section-header h2 { color: #00ff66; font-size: 1.2rem; }
.badge-count { background: #00ff66; color: #111; padding: 2px 10px; border-radius: 20px; font-size: 0.8rem; font-weight: bold; }

/* Table */
.data-table { width: 100%; border-collapse: collapse; background: #111827; border-radius: 12px; overflow: hidden; }
.data-table th { background: #1f2937; color: #00ff66; padding: 12px 14px; text-align: left; font-size: 0.85rem; text-transform: uppercase; letter-spacing: 0.05em; }
.data-table td { padding: 12px 14px; border-bottom: 1px solid #1f2937; color: #e5e5e5; font-size: 0.9rem; vertical-align: middle; }
.data-table tr:hover td { background: #1a2235; }
.data-table tr:last-child td { border-bottom: none; }

/* Status Badges */
.badge { display: inline-block; padding: 3px 10px; border-radius: 20px; font-size: 0.78rem; font-weight: bold; }
.badge-confirmed { background: #052e16; color: #00ff66; border: 1px solid #00ff66; }
.badge-cancelled { background: #450a0a; color: #ef4444; border: 1px solid #ef4444; }
.badge-pending { background: #451a03; color: #f59e0b; border: 1px solid #f59e0b; }
.badge-approved { background: #052e16; color: #00ff66; border: 1px solid #00ff66; }

/* Action Buttons */
.btn-action { padding: 6px 14px; border: none; border-radius: 6px; cursor: pointer; font-size: 0.82rem; font-weight: bold; margin: 2px; }
.btn-approve { background: #00ff66; color: #111; }
.btn-approve:hover { background: #00cc55; }
.btn-delete { background: #dc2626; color: #fff; }
.btn-delete:hover { background: #b91c1c; }

/* Empty State */
.empty-state { text-align: center; padding: 50px; color: #6b7280; }
.empty-state i { font-size: 3rem; margin-bottom: 14px; display: block; }

/* Search */
.search-bar { background: #1f2937; border: 1px solid #374151; color: #e5e5e5; padding: 9px 14px; border-radius: 8px; width: 260px; font-size: 0.9rem; }
.search-bar:focus { outline: none; border-color: #00ff66; }

.table-wrapper { overflow-x: auto; border-radius: 12px; }
</style>
</head>
<body>

<!-- Top Navbar -->
<div class="admin-nav">
  <h1><i class="fas fa-shield-alt"></i> BookMyCNG Admin</h1>
  <div class="nav-right">
    <a href="Home1.jsp" class="nav-link"><i class="fas fa-home"></i> Home</a>
    <a href="Aboutus.jsp" class="nav-link"><i class="fas fa-info-circle"></i> About</a>
    <a href="Home1.jsp#Services1" class="nav-link"><i class="fas fa-cogs"></i> Services</a>
    <span style="color:#9ca3af;font-size:0.9rem">| Admin</span>
    <a href="LogoutServlet" class="btn-logout"><i class="fas fa-sign-out-alt"></i> Logout</a>
  </div>
</div>

<!-- Tab Navigation -->
<div class="tab-nav">
  <button class="tab-btn active" onclick="showTab('dashboard')"><i class="fas fa-chart-pie"></i> Dashboard</button>
  <button class="tab-btn" onclick="showTab('bookings')"><i class="fas fa-calendar-check"></i> All Bookings <% if(confirmedBookings>0){ %><span style="background:#00ff66;color:#111;border-radius:10px;padding:1px 7px;font-size:0.75rem;margin-left:4px;"><%= confirmedBookings %></span><% } %></button>
  <button class="tab-btn" onclick="showTab('users')"><i class="fas fa-users"></i> Users</button>
  <button class="tab-btn" onclick="showTab('pumps')"><i class="fas fa-gas-pump"></i> CNG Stations <% if(pendingPumps>0){ %><span style="background:#f59e0b;color:#111;border-radius:10px;padding:1px 7px;font-size:0.75rem;margin-left:4px;"><%= pendingPumps %></span><% } %></button>
</div>

<div class="admin-content">

<!-- ═══════════════ DASHBOARD TAB ═══════════════ -->
<div id="tab-dashboard" class="tab-panel active">
  <div class="stats-grid">
    <div class="stat-card">
      <div class="stat-icon">👥</div>
      <div class="stat-num"><%= totalUsers %></div>
      <div class="stat-label">Registered Users</div>
    </div>
    <div class="stat-card blue">
      <div class="stat-icon">📅</div>
      <div class="stat-num"><%= totalBookings %></div>
      <div class="stat-label">Total Bookings</div>
    </div>
    <div class="stat-card">
      <div class="stat-icon">✅</div>
      <div class="stat-num"><%= confirmedBookings %></div>
      <div class="stat-label">Confirmed Slots</div>
    </div>
    <div class="stat-card red">
      <div class="stat-icon">❌</div>
      <div class="stat-num"><%= cancelledBookings %></div>
      <div class="stat-label">Cancelled Bookings</div>
    </div>
    <div class="stat-card purple">
      <div class="stat-icon">⛽</div>
      <div class="stat-num"><%= totalPumps %></div>
      <div class="stat-label">CNG Stations</div>
    </div>
    <div class="stat-card yellow">
      <div class="stat-icon">⏳</div>
      <div class="stat-num"><%= pendingPumps %></div>
      <div class="stat-label">Pending Approvals</div>
    </div>
  </div>

  <!-- Recent Bookings on Dashboard -->
  <div class="section-header">
    <h2><i class="fas fa-clock"></i> Recent Bookings</h2>
  </div>
  <div class="table-wrapper">
  <table class="data-table">
    <thead><tr>
      <th>#ID</th><th>User</th><th>Station</th><th>Date</th><th>Slot</th><th>Vehicle</th><th>Status</th><th>Booked At</th>
    </tr></thead>
    <tbody>
    <%
    try {
      PreparedStatement ps = con.prepareStatement(
        "SELECT sb.booking_id, sb.booking_date, sb.slot_time, sb.status, sb.created_at, " +
        "sb.vehicle_number, sb.full_name, sb.phone, " +
        "cp.pump_name FROM slot_bookings sb " +
        "LEFT JOIN cng_pumps cp ON sb.pump_id = cp.pump_id " +
        "ORDER BY sb.created_at DESC LIMIT 10");
      ResultSet rs = ps.executeQuery();
      boolean hasRows = false;
      while (rs.next()) {
        hasRows = true;
        String st = rs.getString("status");
        String badgeCls = "CONFIRMED".equals(st) ? "badge-confirmed" : "CANCELLED".equals(st) ? "badge-cancelled" : "badge-pending";
    %>
    <tr>
      <td>#<%= rs.getInt("booking_id") %></td>
      <td><b><%= rs.getString("full_name") != null ? rs.getString("full_name") : "N/A" %></b><br><small style="color:#6b7280"><%= rs.getString("phone") != null ? rs.getString("phone") : "" %></small></td>
      <td><%= rs.getString("pump_name") != null ? rs.getString("pump_name") : "N/A" %></td>
      <td><%= rs.getDate("booking_date") %></td>
      <td><%= rs.getString("slot_time") %></td>
      <td><%= rs.getString("vehicle_number") != null ? rs.getString("vehicle_number") : "N/A" %></td>
      <td><span class="badge <%= badgeCls %>"><%= st %></span></td>
      <td><small><%= rs.getTimestamp("created_at") != null ? rs.getTimestamp("created_at").toString().substring(0,16) : "N/A" %></small></td>
    </tr>
    <% } if (!hasRows) { %>
    <tr><td colspan="8"><div class="empty-state"><i class="fas fa-inbox"></i>No bookings yet</div></td></tr>
    <% } rs.close(); ps.close();
    } catch (Exception e) { e.printStackTrace(); } %>
    </tbody>
  </table>
  </div>
</div>

<!-- ═══════════════ BOOKINGS TAB ═══════════════ -->
<div id="tab-bookings" class="tab-panel">
  <div class="section-header">
    <h2><i class="fas fa-calendar-check"></i> All Slot Bookings</h2>
    <input class="search-bar" type="text" placeholder="Search by name, vehicle, station..." onkeyup="filterTable('bookings-table', this.value)">
  </div>
  <div class="table-wrapper">
  <table class="data-table" id="bookings-table">
    <thead><tr>
      <th>#ID</th><th>Customer</th><th>Phone</th><th>Email</th><th>Station</th><th>Date</th><th>Slot</th><th>Vehicle Type</th><th>Vehicle No.</th><th>Status</th><th>Booked At</th><th>Action</th>
    </tr></thead>
    <tbody>
    <%
    try {
      PreparedStatement ps = con.prepareStatement(
        "SELECT sb.*, cp.pump_name FROM slot_bookings sb " +
        "LEFT JOIN cng_pumps cp ON sb.pump_id = cp.pump_id " +
        "ORDER BY sb.created_at DESC");
      ResultSet rs = ps.executeQuery();
      boolean hasRows = false;
      while (rs.next()) {
        hasRows = true;
        String st = rs.getString("status");
        String badgeCls = "CONFIRMED".equals(st) ? "badge-confirmed" : "CANCELLED".equals(st) ? "badge-cancelled" : "badge-pending";
    %>
    <tr>
      <td>#<%= rs.getInt("booking_id") %></td>
      <td><b><%= rs.getString("full_name") != null ? rs.getString("full_name") : "N/A" %></b></td>
      <td><%= rs.getString("phone") != null ? rs.getString("phone") : "N/A" %></td>
      <td><small><%= rs.getString("email") != null ? rs.getString("email") : "N/A" %></small></td>
      <td><%= rs.getString("pump_name") != null ? rs.getString("pump_name") : "Station #" + rs.getInt("pump_id") %></td>
      <td><%= rs.getDate("booking_date") %></td>
      <td><%= rs.getString("slot_time") %></td>
      <td><%= rs.getString("vehicle_type") != null ? rs.getString("vehicle_type") : "N/A" %></td>
      <td><%= rs.getString("vehicle_number") != null ? rs.getString("vehicle_number") : "N/A" %></td>
      <td><span class="badge <%= badgeCls %>"><%= st %></span></td>
      <td><small><%= rs.getTimestamp("created_at") != null ? rs.getTimestamp("created_at").toString().substring(0,16) : "N/A" %></small></td>
      <td>
        <form method="post" action="CancelBooking" style="display:inline">
          <input type="hidden" name="bookingId" value="<%= rs.getInt("booking_id") %>">
          <input type="hidden" name="source" value="admin">
          <button type="submit" class="btn-action btn-delete" onclick="return confirm('Cancel this booking?')"><i class="fas fa-times"></i> Cancel</button>
        </form>
      </td>
    </tr>
    <% } if (!hasRows) { %>
    <tr><td colspan="12"><div class="empty-state"><i class="fas fa-inbox"></i>No bookings yet</div></td></tr>
    <% } rs.close(); ps.close();
    } catch (Exception e) { e.printStackTrace(); } %>
    </tbody>
  </table>
  </div>
</div>

<!-- ═══════════════ USERS TAB ═══════════════ -->
<div id="tab-users" class="tab-panel">
  <div class="section-header">
    <h2><i class="fas fa-users"></i> Registered Users</h2>
    <input class="search-bar" type="text" placeholder="Search by name, email, phone..." onkeyup="filterTable('users-table', this.value)">
  </div>
  <div class="table-wrapper">
  <table class="data-table" id="users-table">
    <thead><tr>
      <th>#ID</th><th>Name</th><th>Email</th><th>Mobile</th><th>Registered At</th><th>Total Bookings</th><th>Confirmed</th>
    </tr></thead>
    <tbody>
    <%
    try {
      PreparedStatement ps = con.prepareStatement(
        "SELECT u.user_id, u.name, u.email, u.mobile, u.created_at, " +
        "COUNT(sb.booking_id) AS total_bookings, " +
        "SUM(CASE WHEN sb.status='CONFIRMED' THEN 1 ELSE 0 END) AS confirmed " +
        "FROM users u LEFT JOIN slot_bookings sb ON u.user_id = sb.user_id " +
        "GROUP BY u.user_id ORDER BY u.created_at DESC");
      ResultSet rs = ps.executeQuery();
      boolean hasRows = false;
      while (rs.next()) {
        hasRows = true;
    %>
    <tr>
      <td>#<%= rs.getInt("user_id") %></td>
      <td><b><%= rs.getString("name") != null ? rs.getString("name") : "N/A" %></b></td>
      <td><%= rs.getString("email") != null ? rs.getString("email") : "N/A" %></td>
      <td><%= rs.getString("mobile") != null ? rs.getString("mobile") : "N/A" %></td>
      <td><small><%= rs.getTimestamp("created_at") != null ? rs.getTimestamp("created_at").toString().substring(0,16) : "N/A" %></small></td>
      <td><span class="badge badge-confirmed"><%= rs.getInt("total_bookings") %></span></td>
      <td><span class="badge badge-confirmed"><%= rs.getInt("confirmed") %></span></td>
    </tr>
    <% } if (!hasRows) { %>
    <tr><td colspan="7"><div class="empty-state"><i class="fas fa-users"></i>No users registered yet</div></td></tr>
    <% } rs.close(); ps.close();
    } catch (Exception e) { e.printStackTrace(); } %>
    </tbody>
  </table>
  </div>
</div>

<!-- ═══════════════ CNG STATIONS TAB ═══════════════ -->
<div id="tab-pumps" class="tab-panel">
  <div class="section-header">
    <h2><i class="fas fa-gas-pump"></i> CNG Stations</h2>
    <input class="search-bar" type="text" placeholder="Search by name, city..." onkeyup="filterTable('pumps-table', this.value)">
  </div>
  <div class="table-wrapper">
  <table class="data-table" id="pumps-table">
    <thead><tr>
      <th>#ID</th><th>Station Name</th><th>City</th><th>State</th><th>Mobile</th><th>Price/kg</th><th>CNG Stock</th><th>Hours</th><th>Status</th><th>Actions</th>
    </tr></thead>
    <tbody>
    <%
    try {
      PreparedStatement ps = con.prepareStatement("SELECT * FROM cng_pumps ORDER BY status ASC, pump_id DESC");
      ResultSet rs = ps.executeQuery();
      boolean hasRows = false;
      while (rs.next()) {
        hasRows = true;
        String st = rs.getString("status");
        String badgeCls = "APPROVED".equals(st) ? "badge-approved" : "PENDING".equals(st) ? "badge-pending" : "badge-cancelled";
    %>
    <tr>
      <td>#<%= rs.getInt("pump_id") %></td>
      <td><b><%= rs.getString("pump_name") %></b><br><small style="color:#6b7280"><%= rs.getString("address") != null ? rs.getString("address") : "" %></small></td>
      <td><%= rs.getString("city") != null ? rs.getString("city") : "N/A" %></td>
      <td><%= rs.getString("state") != null ? rs.getString("state") : "N/A" %></td>
      <td><%= rs.getString("mobileNo") != null ? rs.getString("mobileNo") : "N/A" %></td>
      <td>₹<%= rs.getString("price_per_kg") != null ? rs.getString("price_per_kg") : "N/A" %></td>
      <td><%= rs.getInt("cng_kg") %> kg</td>
      <td><small><%= rs.getString("open_time") %> – <%= rs.getString("close_time") %></small></td>
      <td><span class="badge <%= badgeCls %>"><%= st %></span></td>
      <td>
        <% if ("PENDING".equals(st)) { %>
        <form method="post" action="Approve" style="display:inline">
          <input type="hidden" name="pumpId" value="<%= rs.getInt("pump_id") %>">
          <input type="hidden" name="action" value="APPROVED">
          <button type="submit" class="btn-action btn-approve"><i class="fas fa-check"></i> Approve</button>
        </form>
        <% } %>
        <form method="post" action="Approve" style="display:inline">
          <input type="hidden" name="pumpId" value="<%= rs.getInt("pump_id") %>">
          <input type="hidden" name="action" value="DELETE">
          <button type="submit" class="btn-action btn-delete" onclick="return confirm('Delete this station?')"><i class="fas fa-trash"></i> Delete</button>
        </form>
      </td>
    </tr>
    <% } if (!hasRows) { %>
    <tr><td colspan="10"><div class="empty-state"><i class="fas fa-gas-pump"></i>No stations registered yet</div></td></tr>
    <% } rs.close(); ps.close();
    } catch (Exception e) { e.printStackTrace(); } %>
    </tbody>
  </table>
  </div>
</div>

</div><!-- end admin-content -->

<%
  try { if (con != null) con.close(); } catch (Exception e) {}
%>

<script>
function showTab(name) {
  document.querySelectorAll('.tab-panel').forEach(p => p.classList.remove('active'));
  document.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('active'));
  document.getElementById('tab-' + name).classList.add('active');
  event.currentTarget.classList.add('active');
}

function filterTable(tableId, query) {
  var q = query.toLowerCase();
  var rows = document.getElementById(tableId).querySelectorAll('tbody tr');
  rows.forEach(function(row) {
    row.style.display = row.textContent.toLowerCase().includes(q) ? '' : 'none';
  });
}
</script>
</body>
</html>
