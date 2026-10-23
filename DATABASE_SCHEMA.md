# Database Schema for CNG Booking Application

## Database Configuration
- **Database Name**: `cng_booking`
- **Host**: `localhost:3306`
- **Username**: configure with the `DB_USER` environment variable (defaults to `root`)
- **Password**: configure with the `DB_PASS` environment variable

## Required Tables

### 1. `cng_pump` or `cng_pumps` (CNG Pump Information)
**Note**: The codebase uses both table names. Please ensure one of these exists:

**If using `cng_pump`:**
```sql
CREATE TABLE IF NOT EXISTS cng_pump (
    cng_id INT PRIMARY KEY AUTO_INCREMENT,
    pump_name VARCHAR(255) NOT NULL,
    address VARCHAR(500),
    city VARCHAR(100),
    taluka VARCHAR(100),
    district VARCHAR(100),
    state VARCHAR(100),
    mobileNo VARCHAR(20),
    password VARCHAR(255),
    price_per_kg DECIMAL(10,2),
    latitude DECIMAL(10,8),
    longitude DECIMAL(11,8),
    open_time VARCHAR(20),
    close_time VARCHAR(20),
    cng_kg VARCHAR(50),
    status VARCHAR(50) DEFAULT 'PENDING'
);
```

**If using `cng_pumps`:**
```sql
CREATE TABLE IF NOT EXISTS cng_pumps (
    pump_id INT PRIMARY KEY AUTO_INCREMENT,
    pump_name VARCHAR(255) NOT NULL,
    address VARCHAR(500) NOT NULL,
    city VARCHAR(100),
    taluka VARCHAR(100),
    district VARCHAR(100),
    state VARCHAR(100),
    mobileNo VARCHAR(20) NOT NULL UNIQUE,
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    price_per_kg DECIMAL(10,2) NOT NULL DEFAULT 85.00,
    open_time VARCHAR(20) DEFAULT '06:00',
    close_time VARCHAR(20) DEFAULT '22:00',
    latitude DECIMAL(10,8),
    longitude DECIMAL(11,8),
    cng_kg VARCHAR(50) DEFAULT '1000',
    status VARCHAR(50) DEFAULT 'PENDING'
);
```

### 2. `slot_bookings` (Booking Information)
```sql
CREATE TABLE IF NOT EXISTS slot_bookings (
    booking_id INT PRIMARY KEY AUTO_INCREMENT,
    pump_id INT NOT NULL,
    booking_date DATE NOT NULL,
    slot_time VARCHAR(32) NOT NULL,
    user_id INT NOT NULL,
    status VARCHAR(50) DEFAULT 'CONFIRMED',
    vehicle_type VARCHAR(100),
    vehicle_number VARCHAR(50),
    full_name VARCHAR(255),
    phone VARCHAR(20),
    email VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    KEY idx_slot_availability (pump_id, booking_date, slot_time, status),
    KEY idx_user_bookings (user_id),
    FOREIGN KEY (pump_id) REFERENCES cng_pumps(pump_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);
```

### 3. `users` (User Information)
```sql
CREATE TABLE IF NOT EXISTS users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    full_name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20),
    password VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### 4. `admin` (Administrator Login)
```sql
CREATE TABLE IF NOT EXISTS admin (
    admin_id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL
);
```

## Important Notes

1. **Table Name Inconsistency**: The codebase references both `cng_pump` and `cng_pumps`.
   - `SlotBookings.jsp` uses `cng_pumps` with `pump_id`
   - Most other files use `cng_pump` with `cng_id`
   - **Action Required**: Standardize on one table name across the application

2. **Database Connection**: Set `DB_URL`, `DB_USER`, and `DB_PASS` in the environment before running the application. `DB_URL` and `DB_USER` have local-development defaults; `DB_PASS` is required.

3. **MySQL Driver**: Ensure `mysql-connector-j-9.4.0.jar` is in `WEB-INF/lib/`

## Verification Queries

```sql
-- Check if tables exist
SHOW TABLES;

-- Check cng_pump/cng_pumps structure
DESCRIBE cng_pump;
-- OR
DESCRIBE cng_pumps;

-- Check slot_bookings structure
DESCRIBE slot_bookings;

-- Check users table structure
DESCRIBE users;
```
