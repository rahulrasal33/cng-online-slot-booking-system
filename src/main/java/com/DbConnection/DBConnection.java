package com.DbConnection;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnection {
    public static Connection connect() {
        Connection con = null;
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            String dbUrl = System.getenv("DB_URL");
            if (dbUrl == null || dbUrl.trim().isEmpty()) {
                dbUrl = "jdbc:mysql://localhost:3306/cng_booking?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC";
            }

            String dbUser = System.getenv("DB_USER");
            if (dbUser == null || dbUser.trim().isEmpty()) {
                dbUser = "root";
            }

            String dbPass = System.getenv("DB_PASS");
            if (dbPass == null || dbPass.trim().isEmpty()) {
                System.err.println("Database connection unavailable: DB_PASS environment variable is not set.");
                return null;
            }

            con = DriverManager.getConnection(dbUrl, dbUser, dbPass);
            System.out.println("✅ Database Connected Successfully!");
        } catch (ClassNotFoundException e) {
            System.out.println("❌ MySQL JDBC Driver not found!");
            e.printStackTrace();
        } catch (SQLException e) {
            System.out.println("❌ SQL Connection Failed!");
            e.printStackTrace();
        }
        return con;
    }
}
