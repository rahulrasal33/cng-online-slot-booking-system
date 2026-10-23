# Slot Locking and Booking Mechanism Implementation

## Overview
This document describes the robust slot-locking mechanism implemented to prevent double-booking, similar to movie ticket booking systems where once a slot is booked, it's immediately reserved and unavailable for others.

## Problem Statement
The previous implementation allowed race conditions where two users could book the same slot simultaneously because:
1. Both transactions could read "slot available" at the same time
2. Both would proceed to insert, resulting in duplicate bookings

## Solution: Multi-Layer Protection

### Layer 1: Row-Level Locking with SELECT FOR UPDATE
- **SELECT FOR UPDATE**: Locks matching rows during the transaction
- **Transaction Isolation**: Set to SERIALIZABLE for maximum concurrency control
- **How it works**: When Transaction A locks rows, Transaction B must wait until A commits or rolls back

### Layer 2: Atomic INSERT with Subquery Check
- **INSERT ... SELECT ... WHERE NOT EXISTS**: Ensures insert only happens if slot doesn't exist
- **Database-level safety**: Even if application logic fails, database prevents duplicate

### Layer 3: Database Constraints (Recommended)
- **Unique Constraint**: Prevents duplicate (pump_id, booking_date, slot_time) combinations
- **Trigger**: Additional check before insert (optional)

## Implementation Details

### Code Flow:
```java
1. Set transaction isolation to SERIALIZABLE
2. Start transaction (setAutoCommit(false))
3. SELECT ... FOR UPDATE → Locks rows, prevents other transactions from reading
4. Check if slot exists
5. If exists → Rollback and show error
6. If not exists → INSERT with WHERE NOT EXISTS check
7. Commit transaction → Releases lock
8. Restore original isolation level
```

### Key Features:

#### 1. **SELECT FOR UPDATE Locking**
```sql
SELECT booking_id FROM slot_bookings 
WHERE pump_id = ? AND booking_date = ? AND slot_time = ? 
AND status != 'CANCELLED' 
FOR UPDATE
```
- **Locks the rows** that match the condition
- **Blocks other transactions** from reading/modifying these rows
- **Lock is held** until transaction commits or rolls back

#### 2. **SERIALIZABLE Isolation Level**
```java
con.setTransactionIsolation(Connection.TRANSACTION_SERIALIZABLE);
```
- **Highest isolation level**: Prevents phantom reads and ensures strict serialization
- **Trade-off**: Slightly slower but guarantees data integrity
- **Restored** after transaction completes

#### 3. **Atomic INSERT with Check**
```sql
INSERT INTO slot_bookings (...) 
SELECT ?, ?, ?, ... 
WHERE NOT EXISTS (
    SELECT 1 FROM slot_bookings 
    WHERE pump_id = ? AND booking_date = ? AND slot_time = ? 
    AND status != 'CANCELLED'
)
```
- **Single atomic operation**: Check and insert happen together
- **Database-level protection**: Even if application check is bypassed, database prevents duplicate

## How It Prevents Double-Booking

### Scenario 1: Sequential Bookings
1. **User A** starts transaction → Locks rows → Checks → Inserts → Commits
2. **User B** starts transaction → Tries to lock → Waits for A to commit
3. **User B** gets lock → Checks → Finds slot booked → Rolls back → Shows error

### Scenario 2: Simultaneous Bookings (Race Condition)
1. **User A** and **User B** both start transactions simultaneously
2. **User A** acquires lock first → **User B** waits
3. **User A** checks → Slot available → Inserts → Commits → Releases lock
4. **User B** gets lock → Checks → Slot now booked → Rolls back → Shows error

### Scenario 3: Edge Case - Insert Fails
1. Transaction locks rows and checks → Slot available
2. Another transaction somehow inserts (shouldn't happen with proper locking)
3. INSERT with WHERE NOT EXISTS → Returns 0 rows affected
4. Transaction detects 0 rows → Rolls back → Shows error

## Benefits

1. **100% Prevention**: Multiple layers ensure no double-booking possible
2. **Race Condition Safe**: SELECT FOR UPDATE prevents simultaneous access
3. **Database-Level Safety**: INSERT with WHERE NOT EXISTS provides fallback
4. **Immediate Locking**: Slot is locked as soon as transaction starts
5. **Automatic Release**: Lock released on commit/rollback

## Performance Considerations

### Transaction Isolation Levels:
- **READ COMMITTED** (default): Faster but allows race conditions
- **REPEATABLE READ**: Good balance, but may still have issues
- **SERIALIZABLE**: Slowest but guarantees no race conditions ✅ (Used)

### Lock Duration:
- **Minimal**: Lock held only during check and insert (milliseconds)
- **Automatic Release**: On commit or rollback
- **No Deadlocks**: Simple locking pattern prevents deadlocks

## Database Schema Requirements

### Recommended: Add Unique Constraint
```sql
ALTER TABLE slot_bookings 
ADD CONSTRAINT unique_active_booking 
UNIQUE (pump_id, booking_date, slot_time);
```

**Note**: This prevents ALL duplicates. If you want cancelled slots to be rebookable, use a trigger instead (see PREVENT_DOUBLE_BOOKING.sql).

## Testing

### Test Case 1: Normal Booking
1. User books slot → Should succeed
2. Same user tries to book same slot → Should show error

### Test Case 2: Concurrent Bookings
1. Two users try to book same slot simultaneously
2. Expected: One succeeds, one gets error
3. Verify: Only one booking exists in database

### Test Case 3: Lock Behavior
1. User A starts booking (don't complete)
2. User B tries to book same slot
3. Expected: User B waits until User A completes
4. If User A commits → User B gets error
5. If User A rolls back → User B can proceed

## Files Modified

1. **UserBooking.java**: Added SELECT FOR UPDATE, SERIALIZABLE isolation, atomic INSERT
2. **UBooking.java**: Added SELECT FOR UPDATE, SERIALIZABLE isolation, atomic INSERT

## Error Messages

- **Slot Already Booked**: "❌ This time slot is already booked by another user. Please select a different time slot."
- **Slot Just Booked**: "❌ This time slot was just booked by another user. Please select a different time slot."

## Monitoring

To monitor lock behavior:
```sql
-- Check for locked transactions
SHOW PROCESSLIST;

-- Check for duplicate bookings (should return 0)
SELECT pump_id, booking_date, slot_time, COUNT(*) as count
FROM slot_bookings
WHERE status != 'CANCELLED'
GROUP BY pump_id, booking_date, slot_time
HAVING COUNT(*) > 1;
```

## Future Enhancements

1. **Reservation Timeout**: Auto-release slots if not confirmed within X minutes
2. **Lock Timeout**: Set maximum wait time for acquiring locks
3. **Queue System**: Allow users to join waitlist for popular slots
4. **Notification**: Notify users when a slot becomes available
