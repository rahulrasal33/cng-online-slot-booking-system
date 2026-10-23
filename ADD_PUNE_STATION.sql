-- Run this script in your MySQL Workbench or phpMyAdmin to add a live Pune station
USE cng_booking;

INSERT INTO cng_pumps (
    pump_name, 
    address, 
    city, 
    district, 
    state, 
    mobileNo, 
    password, 
    price_per_kg, 
    latitude, 
    longitude, 
    open_time, 
    close_time, 
    cng_kg, 
    status
) VALUES (
    'Pune Live CNG Station', 
    'Shivajinagar, Near JM Road', 
    'Pune', 
    'Pune', 
    'Maharashtra', 
    '9876543210', 
    '123456', 
    '85.00', 
    18.5314, 
    73.8446, 
    '00:00', 
    '23:59', 
    '1000', 
    'APPROVED'
);
