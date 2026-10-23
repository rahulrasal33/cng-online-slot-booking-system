package CngBooking;

import java.sql.Connection;
import java.sql.PreparedStatement;

final class SlotHoldTable {
    static final String TABLE = "slot_holds";

    private SlotHoldTable() {}

    static void ensureExists(Connection con) throws Exception {
        String ddl =
                "CREATE TABLE IF NOT EXISTS " + TABLE + " (" +
                "  hold_id BIGINT AUTO_INCREMENT PRIMARY KEY," +
                "  pump_id INT NOT NULL," +
                "  booking_date DATE NOT NULL," +
                "  slot_time VARCHAR(32) NOT NULL," +
                "  user_id INT NOT NULL," +
                "  session_id VARCHAR(128) NOT NULL," +
                "  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP," +
                "  expires_at TIMESTAMP NOT NULL," +
                "  UNIQUE KEY uq_hold (pump_id, booking_date, slot_time)," +
                "  KEY idx_expires (expires_at)," +
                "  KEY idx_user (user_id)" +
                ") ENGINE=InnoDB";

        PreparedStatement pst = con.prepareStatement(ddl);
        pst.execute();
        pst.close();
    }

    static int deleteExpired(Connection con) throws Exception {
        PreparedStatement pst = con.prepareStatement(
                "DELETE FROM " + TABLE + " WHERE expires_at <= NOW()"
        );
        int count = pst.executeUpdate();
        pst.close();
        return count;
    }
}

