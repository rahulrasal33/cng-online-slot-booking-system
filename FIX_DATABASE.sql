-- Fix Database Structure for CNG Booking App
-- Run this script in MySQL Workbench or command line

USE cng_booking;

-- Check current structure of slot_bookings table
DESCRIBE slot_bookings;

-- If status column is too small, alter it:
ALTER TABLE slot_bookings MODIFY COLUMN status VARCHAR(50) DEFAULT 'CONFIRMED';

-- Or if status is an ENUM, you might need to drop and recreate:
-- First, check if it's an ENUM:
-- SHOW COLUMNS FROM slot_bookings WHERE Field = 'status';

-- If status is ENUM, you can change it to VARCHAR:
-- ALTER TABLE slot_bookings MODIFY COLUMN status VARCHAR(50) DEFAULT 'CONFIRMED';

-- Verify the change:
DESCRIBE slot_bookings;

-- Test insert (optional - remove after testing):
-- INSERT INTO slot_bookings (pump_id, booking_date, slot_time, user_id, vehicle_type, vehicle_number, full_name, phone, email)
-- VALUES (1, '2024-01-15', '10:00 AM', 1, 'Car', 'DL01AB1234', 'Test User', '1234567890', 'test@example.com');

-- Check if data was inserted:
-- SELECT * FROM slot_bookings ORDER BY booking_id DESC LIMIT 5;

