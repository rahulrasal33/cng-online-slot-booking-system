    <%@ page import="io.jsonwebtoken.Claims" %>
<%@ page import="io.jsonwebtoken.JwtException" %>
<%@ page import="CngBooking.JWTUtils" %>
<%@ page import="javax.servlet.http.Cookie" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Document</title>
    <style>
        
* {
  box-sizing: border-box;
  margin: 0;
  padding: 0;
  font-family: "Segoe UI", sans-serif;
}

body {
  background: #0d1117;
  color: #e6e6e6;
}


/* .navbar {
    background: #277dfe00;
  color: #fff;
  padding: 1px 0;
  position: sticky;
  top: 0;
  z-index: 1000;
  display: flex;
  justify-content: center;
} */

.container {

  margin: auto;
  padding: 0 20px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  width: 100%;
}

.container .logo {
  font-size: 20px;
  font-weight: bold;
  color: #ffffff;
}

.nav-links ul {
  list-style: none;
  display: flex;
  margin: 0;
  padding: 0;
}

.nav-links li {
  margin-left: 20px;
}

.nav-links a {
  color: #bbb;
  text-decoration: none;
  font-size: 16px;
  transition: color 0.3s;
}

.nav-links a:hover {
  color: #00c853;
}

.btn {
  background: #00c853;
  color: #fff;
  padding: 8px 16px;
  border-radius: 5px;
  text-decoration: none;
  font-size: 14px;
  transition: background 0.3s;
  align-items: center;
  font-weight: 700;
  
}
.btn1{
  text-decoration: none;
  padding: 8px 16px;
  color: white;
  border-radius: 5px;
    font-size: 14px;
    font-weight: 700;

}
.btn1:hover{
  color: rgb(0, 172, 0);
    padding: 8px 16px;

}

.btn:hover {
  background: #00a046;
}

/* Hamburger Menu */
.hamburger {
  display: none;
  flex-direction: column;
  cursor: pointer;
}

.hamburger span {
  height: 3px;
  width: 25px;
  background: #fff;
  margin: 4px 0;
  border-radius: 2px;
}

/* Responsive */
@media (max-width: 768px) {
  .nav-links {
    display: none;
    position: absolute;
    top: 60px;
    right: 20px;
    background: #0d1117;
    width: 200px;
    border-radius: 8px;
    padding: 15px;
  }

  .nav-links ul {
    flex-direction: column;
  }

  .nav-links li {
    margin: 10px 0;
  }

  .hamburger {
    display: flex;
  }

  .nav-links.active {
    display: block;
  }
}
/* background: linear-gradient(90deg , rgb(12, 12, 12), #0c1324); */
/* box-shadow: 0 1px 4px rgba(0, 0, 0, 0.4); */
.navbar {
    background: transparent;
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 14px 40px;

  position: fixed; /* Always stays at the top */
  top: 0;
  left: 0;
  width: 100%;     /* Full width */
  z-index: 1000;   /* Stays above other elements */
}


.logo {
  display: flex;
  align-items: center;
  gap: 10px;
  font-size: 1.2rem;
  font-weight: bold;
  color: #16a34a;
}

nav a {
  margin: 0 15px;
  text-decoration: none;
  color: #e6e6e6;
  font-weight: 500;
}

.nav-actions {
  display: flex;
  align-items: center;
  gap: 20px;
}

.btn-primary {
  background-color: #16a34a;
  color: white;
  border: none;
  padding: 10px 20px;
  border-radius: 6px;
  cursor: pointer;
  font-weight: bold;
  margin-top: 10px;
  margin-bottom: 10px;
}

.btn-outline {
  background: transparent;
  border: 2px solid #16a34a;
  color: #16a34a;
  padding: 10px 20px;
  border-radius: 6px;
  cursor: pointer;
  font-weight: bold;
}

@media (max-width: 768px) {
  .navbar {
    padding: 8px 12px;
    background: rgba(13, 17, 23, 0.96);
  }

  .navbar .container {
    min-width: 0;
    padding: 0;
    gap: 8px;
  }

  .navbar .logo {
    flex: 0 1 auto;
    min-width: 0;
    font-size: 1rem;
    white-space: nowrap;
  }

  .navbar .nav-links {
    display: none;
    position: absolute;
    top: calc(100% + 8px);
    left: 12px;
    right: 12px;
    width: auto;
    padding: 12px;
    border: 1px solid #263244;
    background: #0d1117;
    box-shadow: 0 12px 28px rgba(0, 0, 0, 0.45);
  }

  .navbar .nav-links.active {
    display: block;
  }

  .navbar .nav-links ul {
    display: flex;
    flex-direction: column;
  }

  .navbar .nav-links li {
    margin: 0;
  }

  .navbar .nav-links a {
    display: block;
    margin: 0;
    padding: 12px;
  }

  .navbar .buttons {
    display: flex;
    align-items: center;
    gap: 4px;
    margin-left: auto;
    white-space: nowrap;
  }

  .navbar .buttons a {
    padding: 8px 9px;
    font-size: 13px;
  }

  .navbar .hamburger {
    display: flex;
    flex: 0 0 40px;
    width: 40px;
    height: 40px;
    align-items: center;
    justify-content: center;
    padding: 4px;
    border: 0;
    background: transparent;
  }
}

@media (max-width: 360px) {
  .navbar .logo {
    font-size: 0.9rem;
  }

  .navbar .buttons a {
    padding: 7px 6px;
    font-size: 12px;
  }
}

    </style>
</head>
<body>
<%
    String role = null;
    boolean loggedIn = false;

    // First check session attributes (more reliable for immediate post-login)
    HttpSession httpSession = request.getSession(false);
    if (httpSession != null && httpSession.getAttribute("userId") != null) {
        loggedIn = true;
        // Check if role is set in session, otherwise determine from context
        String sessionRole = (String) httpSession.getAttribute("role");
        if (sessionRole != null) {
            role = sessionRole;
        } else {
            // If no role in session, check JWT token
            Cookie[] cookies = request.getCookies();
            if (cookies != null) {
                for (Cookie c : cookies) {
                    if ("jwtToken".equals(c.getName())) {
                        try {
                            io.jsonwebtoken.Claims claims = CngBooking.JWTUtils.validateToken(c.getValue());
                            role = (String) claims.get("role");
                            if (role == null) {
                                role = "USER"; // Default to USER if logged in but no role
                            }
                        } catch (Exception e) {
                            role = "USER"; // Default to USER if JWT fails but session exists
                        }
                    }
                }
            } else {
                role = "USER"; // Default to USER if session exists but no JWT
            }
        }
    } else {
        // If no session, check JWT token as fallback
        Cookie[] cookies = request.getCookies();
        if (cookies != null) {
            for (Cookie c : cookies) {
                if ("jwtToken".equals(c.getName())) {
                    try {
                        io.jsonwebtoken.Claims claims = CngBooking.JWTUtils.validateToken(c.getValue());
                        loggedIn = true;
                        role = (String) claims.get("role");
                    } catch (Exception e) {
                        loggedIn = false;
                    }
                }
            }
        }
    }
%>

    <header class="navbar">
  <div class="container">
    <div class="logo">BookMyCNG</div>

    <nav class="nav-links" id="primaryNavigation" onclick="if (event.target.closest('a')) { this.classList.remove('active'); const button = this.closest('.container').querySelector('.hamburger'); button.setAttribute('aria-expanded', 'false'); button.setAttribute('aria-label', 'Open navigation menu'); }">
      <ul>
       <%
 
          if (loggedIn && "USER".equals(role)) {
      %>         
        <li><a href="Home1.jsp">Home</a></li>
        <li><a href="#Stations">Find Stations</a></li>
        <li><a href="PumpOrders">My Orders</a></li>
        <li><a href="PumpProfile.jsp">My Station</a></li>
        <li><a href="Aboutus.jsp">About</a></li>
         <li>
		     <a href="SlotBookings.jsp">Book Now</a>
		  </li>
      <%
          } else if (loggedIn && "SELLER".equals(role)) {

		%>
		 <li><a href="Home1.jsp">Home</a></li>
        <li><a href="PumpOrders">My Orders</a></li>
        <li><a href="PumpProfile.jsp">My Station</a></li>
        <li><a href="Aboutus.jsp">About</a></li>
         <li><a href="#contact-section">Contact</a></li>
          
          <%
          } else if (loggedIn && "ADMIN".equals(role)) { 
		%>
			
        <li><a href="#">Home</a></li>
        <li><a href="#">Services</a></li>
        <li><a href="Aboutus.jsp">About</a></li>
        <li><a href="#">ManageUsers</a></li>
          <%
		}else {
      %>
         
        <li><a href="Home1.jsp">Home</a></li>
        <li><a href="#">Find Stations</a></li>
        <li><a href="#">Services</a></li>
        <li><a href="Aboutus.jsp">About</a></li>
        <li  onclick="alert('Please login first! Redirecting...'); window.location.href='Login.jsp';">
		      <a href="#" >Book Now</a>
		</li>
      <%
          }
      %>
      </ul>
    </nav>
	<div class="buttons">
      <%
 
         if (loggedIn && "USER".equals(role)) {
      %>
          <!-- User is logged in -->
          <a href="UserProfile.jsp" class="btn1">Profile</a>
          <a href="LogoutServlet" class="btn">Logout</a>
      <%
          }else if (loggedIn && "SELLER".equals(role)) {
		%>
		  <a href="PumpProfile.jsp" class="btn1">Profile</a>
          <a href="LogoutServlet" class="btn">Logout</a>
          
          <%
          }else if (loggedIn && "ADMIN".equals(role)) {
		%>
			<a href="LogoutServlet" class="btn">Logout</a>
          <%
		}else {
      %>
          <!-- User is not logged in -->
          <a href="signup.jsp" class="btn1">Signup</a>
          <a href="Login.jsp" class="btn">Login</a>
      <%
          }
      %>
    </div>


    <!-- Hamburger menu -->
    <button class="hamburger" type="button" aria-label="Open navigation menu" aria-expanded="false" aria-controls="primaryNavigation" onclick="const menu = this.closest('.container').querySelector('.nav-links'); const expanded = menu.classList.toggle('active'); this.setAttribute('aria-expanded', expanded); this.setAttribute('aria-label', expanded ? 'Close navigation menu' : 'Open navigation menu');">
      <span></span>
      <span></span>
      <span></span>
    </button>
  </div>
</header>
</body>
</html>