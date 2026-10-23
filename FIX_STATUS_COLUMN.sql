-- URGENT: Fix the status column in slot_bookings table
-- Run this in MySQL Workbench or command line

USE cng_booking;

-- Check current status column definition
SHOW COLUMNS FROM slot_bookings WHERE Field = 'status';

-- Option 1: If status is VARCHAR with small size, increase it:
ALTER TABLE slot_bookings MODIFY COLUMN status VARCHAR(50) DEFAULT NULL;

-- Option 2: If status is ENUM, change it to VARCHAR:
-- ALTER TABLE slot_bookings MODIFY COLUMN status VARCHAR(50) DEFAULT NULL;

-- Option 3: If you want to keep a default value, use a short one:
-- ALTER TABLE slot_bookings MODIFY COLUMN status VARCHAR(50) DEFAULT 'OK';

-- Verify the change:
DESCRIBE slot_bookings;

-- Check the status column specifically:
SHOW COLUMNS FROM slot_bookings WHERE Field = 'status';

