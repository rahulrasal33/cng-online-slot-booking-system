# Tomcat Startup Troubleshooting Guide

## Issue: "Server Tomcat v9.0 Server at localhost failed to start"

This guide will help you resolve the Tomcat startup issue.

## ✅ Fixed Issues

1. **JWTAuthFilter Missing Methods** - Fixed by adding `init()` and `destroy()` methods

## Common Solutions

### 1. Clean and Rebuild Project

**In Eclipse:**
1. Right-click on the project → **Clean...**
2. Select your project → **Clean**
3. Right-click on the project → **Build Project**

**Or manually:**
```bash
# Delete build folder
rmdir /s /q build\classes

# Rebuild (Eclipse will do this automatically)
```

### 2. Check Port 8080 Availability

Port 8080 is currently **FREE** (verified). If you get a port conflict error:

**Option A: Stop conflicting process**
```cmd
netstat -ano | findstr :8080
taskkill /PID <PID_NUMBER> /F
```

**Option B: Change Tomcat port**
1. In Eclipse: **Servers** tab → Right-click **Tomcat v9.0** → **Open**
2. Change **HTTP/1.1 Port** from 8080 to 8081 (or another free port)
3. Save and restart

### 3. Verify Dependencies

All required JAR files are present in `src/main/webapp/WEB-INF/lib/`:
- ✅ mysql-connector-j-9.4.0.jar
- ✅ javax.servlet-api-4.0.1.jar
- ✅ jjwt-api-0.11.5.jar
- ✅ jjwt-impl-0.11.5.jar
- ✅ jjwt-jackson-0.11.5.jar
- ✅ json-20230227.jar
- ✅ jackson-annotations-2.20.jar
- ✅ jackson-core-2.20.0.jar
- ✅ jackson-databind-2.20.0.jar

### 4. Check Tomcat Server Configuration

**In Eclipse:**
1. **Servers** tab → Right-click **Tomcat v9.0** → **Properties**
2. Verify:
   - **Server path** is correct
   - **Deploy path** is set to `wtpwebapps`
   - **Server locations** → Select **Use Tomcat installation**

### 5. Check for Detailed Error Messages

1. Click **Details >>** in the error dialog
2. Check **Console** view in Eclipse for full stack trace
3. Check **Servers** tab → **Tomcat v9.0** → **View Log**

Common error patterns:
- **Port already in use**: Change port or kill process
- **ClassNotFoundException**: Rebuild project
- **Filter initialization error**: Check web.xml filter configuration
- **Database connection**: Shouldn't prevent startup, but check DBConnection.java

### 6. Verify Project Facets

1. Right-click project → **Properties** → **Project Facets**
2. Ensure:
   - ✅ **Java** is checked (version 1.8)
   - ✅ **Dynamic Web Module** is checked (version 2.5 or 3.0)
   - ✅ **JavaScript** is checked

### 7. Remove and Re-add Server

If nothing works:
1. **Servers** tab → Right-click **Tomcat v9.0** → **Delete** (keep configuration)
2. Right-click in **Servers** tab → **New** → **Server**
3. Select **Apache** → **Tomcat v9.0 Server**
4. Add your project to the server
5. Start the server

### 8. Manual Deployment (Alternative)

If Eclipse deployment fails:
1. Build WAR file: Right-click project → **Export** → **WAR file**
2. Copy WAR to Tomcat's `webapps` folder
3. Start Tomcat from command line:
```cmd
cd C:\path\to\tomcat\bin
startup.bat
```

## Database Connection Note

The database connection in `DBConnection.java` won't prevent Tomcat from starting. Before using database features, configure:
- `DB_URL` (optional; defaults to the local `cng_booking` database)
- `DB_USER` (optional; defaults to `root`)
- `DB_PASS` (required; your MySQL password)
- `JWT_SECRET` (required; use a random value at least 32 bytes long)
- `GEMINI_API_KEY` (optional; required only for the chatbot)

In Eclipse, set these in the Tomcat server's launch configuration under **Environment**. On Windows PowerShell, you can set them before starting Eclipse:
```powershell
$env:DB_PASS = "your_mysql_password"
$env:JWT_SECRET = "replace-with-a-random-secret-at-least-32-bytes-long"
$env:GEMINI_API_KEY = "your_gemini_api_key"
```

Do not commit real credentials or API keys. If previously exposed credentials were active, revoke or rotate them.

## Deploying on Render

1. Push the project to GitHub, then create a **Web Service** on Render connected to the repository.
2. Select **Docker** as the runtime and use the repository's `Dockerfile`.
3. Set these environment variables in Render:
   - `DB_URL`: JDBC URL for a publicly reachable MySQL database
   - `DB_USER`: database username
   - `DB_PASS`: database password
   - `JWT_SECRET`: a random secret at least 32 bytes long
   - `GEMINI_API_KEY`: optional; only needed for the chatbot
4. Ensure the database schema and tables are set up before using the application.

The Docker image builds the Java sources and runs the app on Tomcat 9, matching its `javax.servlet` API. It binds Tomcat to Render's `PORT` environment variable.

## Quick Fix Checklist

- [ ] Clean and rebuild project
- [ ] Check port 8080 is free
- [ ] Verify all JAR files in WEB-INF/lib
- [ ] Check Tomcat server configuration
- [ ] View detailed error logs
- [ ] Verify project facets
- [ ] Try removing and re-adding server

## Next Steps

After fixing the startup issue:
1. Access: `http://localhost:8080/Vehicle_CNG_Booking_App/`
2. Or: `http://localhost:8080/Vehicle_CNG_Booking_App/Home1.jsp`

If you still encounter issues, check the **Console** and **Servers** log for specific error messages.
