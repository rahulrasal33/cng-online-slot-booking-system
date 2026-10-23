# Double Booking Prevention Implementation

## Overview
This document describes how the system prevents double-booking of time slots, similar to movie ticket booking systems where once a slot is booked, it becomes unavailable for others.

## Implementation Details

### 1. **Backend Validation (Application Level)**
Both `UserBooking.java` and `UBooking.java` now include:

- **Pre-booking Check**: Before inserting a new booking, the system checks if the slot is already booked
- **Transaction Management**: Uses database transactions to ensure atomicity
- **Race Condition Prevention**: The check and insert happen within the same transaction

#### Code Flow:
```java
1. Start transaction (setAutoCommit(false))
2. Check if slot exists: SELECT COUNT(*) WHERE pump_id, date, slot_time, status != 'CANCELLED'
3. If count > 0: Rollback and show error message
4. If count == 0: Proceed with INSERT
5. Commit transaction
6. If any error: Rollback transaction
```

### 2. **Frontend Prevention (User Experience)**
- **Visual Indication**: Booked slots are grayed out with a red "✕" mark
- **Click Prevention**: Booked slots cannot be clicked
- **Real-time Updates**: Slots update automatically when station/date changes
- **User Feedback**: Alert message if user tries to select booked slot

### 3. **Database Level (Optional but Recommended)**

#### Option A: Unique Constraint
```sql
ALTER TABLE slot_bookings 
ADD CONSTRAINT unique_active_booking 
UNIQUE (pump_id, booking_date, slot_time);
```

**Note**: This prevents ALL duplicate bookings, including cancelled ones. If you want cancelled slots to be rebookable, use Option B.

#### Option B: Database Trigger
```sql
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
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'This time slot is already booked.';
    END IF;
END;
```

This allows cancelled bookings to be rebooked while preventing active double-bookings.

## How It Works

### Scenario 1: Normal Booking
1. User A selects slot "10:00 AM" for Station 1 on 2024-01-20
2. System checks: Slot available ✅
3. Booking inserted successfully
4. Slot now shows as "booked" for all other users

### Scenario 2: Double Booking Attempt
1. User A selects slot "10:00 AM" for Station 1 on 2024-01-20
2. User B simultaneously selects the same slot
3. **User A's request**:
   - Check: Slot available ✅
   - Insert: Success ✅
   - Commit: Done ✅
4. **User B's request**:
   - Check: Slot already booked ❌ (count = 1)
   - Rollback: Transaction cancelled
   - Error message: "This time slot is already booked by another user"

### Scenario 3: Race Condition Handling
Even if two requests arrive simultaneously:
- Both start transactions
- Both check availability (both see count = 0)
- First request inserts and commits
- Second request tries to insert → Database constraint/trigger prevents it OR application check catches it
- Second request rolls back and shows error

## Benefits

1. **Data Integrity**: Ensures no duplicate bookings exist
2. **User Experience**: Clear feedback when slots are unavailable
3. **Concurrency Safe**: Handles simultaneous booking attempts
4. **Transaction Safety**: All-or-nothing approach prevents partial bookings

## Testing

To test double-booking prevention:

1. **Test Case 1**: Book a slot, then try to book the same slot again
   - Expected: First booking succeeds, second shows error

2. **Test Case 2**: Two users try to book the same slot simultaneously
   - Expected: One succeeds, one gets error message

3. **Test Case 3**: Cancel a booking, then try to rebook
   - Expected: Should succeed (cancelled bookings don't block new bookings)

## Files Modified

1. `src/main/java/CngBooking/UserBooking.java` - Added pre-booking check and transaction management
2. `src/main/java/CngBooking/UBooking.java` - Added pre-booking check and transaction management
3. `PREVENT_DOUBLE_BOOKING.sql` - Database-level constraints (optional)

## Error Messages

- **Slot Already Booked**: "❌ This time slot is already booked by another user. Please select a different time slot."
- **Database Error**: Standard error handling with rollback

## Future Enhancements

1. **Lock Mechanism**: Implement row-level locking for better concurrency
2. **Reservation Timeout**: Auto-release slots if not confirmed within X minutes
3. **Queue System**: Allow users to join a waitlist for popular slots
4. **Notification**: Notify users when a slot becomes available
