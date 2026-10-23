-- SQL Script to Prevent Double Booking
-- This script adds a unique constraint to prevent the same slot from being booked twice

-- Option 1: Add a UNIQUE constraint on (pump_id, booking_date, slot_time, status)
-- This ensures that the same slot cannot be booked twice for the same pump, date, and time
-- Note: This allows cancelled bookings to be rebooked

-- First, check if there are any duplicate bookings
SELECT pump_id, booking_date, slot_time, COUNT(*) as count
FROM slot_bookings
WHERE status != 'CANCELLED'
GROUP BY pump_id, booking_date, slot_time
HAVING COUNT(*) > 1;

-- If duplicates exist, you may want to clean them up first
-- (Keep the first booking, delete others)
-- DELETE t1 FROM slot_bookings t1
-- INNER JOIN slot_bookings t2 
-- WHERE t1.booking_id > t2.booking_id 
-- AND t1.pump_id = t2.pump_id 
-- AND t1.booking_date = t2.booking_date 
-- AND t1.slot_time = t2.slot_time
-- AND t1.status != 'CANCELLED' AND t2.status != 'CANCELLED';

-- Add unique index to prevent future double bookings
-- This will prevent inserting duplicate (pump_id, booking_date, slot_time) combinations
-- where status is not 'CANCELLED'

CREATE UNIQUE INDEX idx_unique_slot_booking 
ON slot_bookings (pump_id, booking_date, slot_time, status)
WHERE status != 'CANCELLED';

-- Note: MySQL doesn't support filtered indexes like PostgreSQL.
-- For MySQL, use a different approach:

-- Option 2: Add a unique constraint excluding cancelled bookings
-- MySQL 8.0+ supports functional indexes, but for older versions:

-- Create a unique index on all non-cancelled bookings
-- Since MySQL doesn't support partial unique indexes directly,
-- we'll rely on application-level checking (which we've implemented in Java)

-- However, we can add a regular unique constraint and handle cancelled bookings in application:
ALTER TABLE slot_bookings 
ADD CONSTRAINT unique_active_booking 
UNIQUE (pump_id, booking_date, slot_time);

-- If the above fails due to existing duplicates, clean them first, then add the constraint.

-- Option 3: Use a trigger (more complex but handles edge cases)
DELIMITER $$

CREATE TRIGGER prevent_double_booking
BEFORE INSERT ON slot_bookings
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1 FROM slot_bookings
        WHERE pump_id = NEW.pump_id
        AND booking_date = NEW.booking_date
        AND slot_time = NEW.slot_time
        AND status != 'CANCELLED'
        AND booking_id != NEW.booking_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'This time slot is already booked. Please select another slot.';
    END IF;
END$$

DELIMITER ;

-- Verify the constraint/trigger works
-- Try inserting a duplicate booking (should fail):
-- INSERT INTO slot_bookings (pump_id, booking_date, slot_time, user_id, status)
-- VALUES (1, '2024-01-20', '10:00 AM', 2, 'CONFIRMED');
-- (This should fail if a booking already exists for pump_id=1, date='2024-01-20', slot='10:00 AM')
