-- Script to Fix Existing Duplicate Bookings and Add Prevention

-- Step 1: Check for existing duplicate bookings
SELECT 
    pump_id, 
    booking_date, 
    slot_time, 
    COUNT(*) as duplicate_count,
    GROUP_CONCAT(booking_id ORDER BY booking_id) as booking_ids
FROM slot_bookings
WHERE status != 'CANCELLED'
GROUP BY pump_id, booking_date, slot_time
HAVING COUNT(*) > 1;

-- Step 2: Keep the first booking (lowest booking_id) and mark others as CANCELLED
-- This preserves booking history while fixing duplicates
UPDATE slot_bookings sb1
INNER JOIN (
    SELECT 
        pump_id, 
        booking_date, 
        slot_time,
        MIN(booking_id) as first_booking_id
    FROM slot_bookings
    WHERE status != 'CANCELLED'
    GROUP BY pump_id, booking_date, slot_time
    HAVING COUNT(*) > 1
) duplicates ON sb1.pump_id = duplicates.pump_id
    AND sb1.booking_date = duplicates.booking_date
    AND sb1.slot_time = duplicates.slot_time
SET sb1.status = 'CANCELLED',
    sb1.email = CONCAT(COALESCE(sb1.email, ''), ' [DUPLICATE_REMOVED]')
WHERE sb1.booking_id != duplicates.first_booking_id
    AND sb1.status != 'CANCELLED';

-- Step 3: Verify no duplicates remain (should return 0 rows)
SELECT 
    pump_id, 
    booking_date, 
    slot_time, 
    COUNT(*) as count
FROM slot_bookings
WHERE status != 'CANCELLED'
GROUP BY pump_id, booking_date, slot_time
HAVING COUNT(*) > 1;

-- Step 4: Add unique constraint to prevent future duplicates
-- First, check if constraint already exists
SELECT 
    CONSTRAINT_NAME,
    TABLE_NAME
FROM information_schema.TABLE_CONSTRAINTS
WHERE TABLE_SCHEMA = 'cng_booking'
    AND TABLE_NAME = 'slot_bookings'
    AND CONSTRAINT_TYPE = 'UNIQUE'
    AND CONSTRAINT_NAME LIKE '%booking%';

-- If constraint doesn't exist, add it:
-- Note: This will fail if duplicates still exist, so run Step 2 first
ALTER TABLE slot_bookings 
ADD CONSTRAINT unique_active_booking 
UNIQUE (pump_id, booking_date, slot_time);

-- Alternative: If you want to allow cancelled bookings to be rebooked,
-- use a trigger instead (see PREVENT_DOUBLE_BOOKING.sql)

-- Step 5: Verify constraint was added
SHOW CREATE TABLE slot_bookings;

-- Step 6: Test the constraint (should fail)
-- INSERT INTO slot_bookings (pump_id, booking_date, slot_time, user_id, status)
-- VALUES (1, '2026-01-23', '01:00 AM', 999, 'CONFIRMED');
-- (Replace with actual values from your duplicate bookings)
