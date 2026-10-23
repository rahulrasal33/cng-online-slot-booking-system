# GPS-Based Distance Calculation and Station Sorting

## Overview
The "View All Stations" page now uses GPS/location data to calculate distances between the user and CNG stations, displaying them in ascending order (nearest first) with real-time availability information.

## Features Implemented

### 1. **GPS Location Detection**
- Uses browser's Geolocation API
- Automatically requests user location permission
- Falls back gracefully if location is denied

### 2. **Distance Calculation (Haversine Formula)**
- Calculates great-circle distance between two coordinates
- Accurate for Earth's spherical surface
- Returns distance in kilometers
- Formula: `d = 2R × arcsin(√(sin²(Δlat/2) + cos(lat1) × cos(lat2) × sin²(Δlon/2)))`

### 3. **Automatic Sorting by Distance**
- When user location is available, stations are automatically sorted by distance
- Nearest stations appear first (ascending order)
- Sort order: Nearest → Farthest

### 4. **Real-Time Slot Availability**
- Fetches available booking slots for each station
- Shows: Available slots / Total slots / Booked slots
- Updates based on today's date (can be changed)
- Color-coded status:
  - **Green**: Available slots
  - **Orange**: Limited slots (≤5 available)
  - **Red**: Fully booked

### 5. **Station Details Display**
Each station card shows:
- **Station Name**: Full name of the CNG station
- **Address**: Complete address with city
- **Distance**: Calculated distance from user (in km)
- **Price**: Price per kg
- **Available Slots**: Real-time slot availability
- **Status**: Open/Closed status
- **Contact**: Phone number
- **Actions**: Reserve Slot, Show on Map

## Implementation Details

### Backend (Java)

#### StationAvailabilityServlet.java
- **Endpoint**: `/getStationAvailability`
- **Parameters**: 
  - `date` (optional): Booking date (defaults to today)
  - `stationIds` (optional): Comma-separated station IDs
- **Returns**: JSON array with availability data for each station
  ```json
  [
    {
      "stationId": 1,
      "date": "2026-01-23",
      "totalSlots": 24,
      "bookedSlots": 5,
      "availableSlots": 19
    }
  ]
  ```

### Frontend (JavaScript)

#### Key Functions:

1. **getUserLocation()**
   - Requests GPS permission
   - Gets user's latitude/longitude
   - Triggers station loading with distance calculation

2. **calculateDistance(lat1, lon1, lat2, lon2)**
   - Implements Haversine formula
   - Returns distance in kilometers

3. **loadStations()**
   - Fetches stations from `/getPumps`
   - Fetches availability from `/getStationAvailability`
   - Calculates distances if location available
   - Auto-sorts by distance (nearest first)

4. **sortStations()**
   - Sorts by: Distance, Price, Availability, or Name
   - Distance sorting: Ascending (nearest first)

## User Experience Flow

1. **User opens "View All Stations" page**
   - Page loads all stations
   - Shows loading indicator

2. **User clicks "Use My Location"**
   - Browser requests location permission
   - If granted: Location captured
   - Stations automatically sorted by distance
   - Nearest station appears first

3. **Stations Display**
   - Each card shows distance from user
   - Available slots displayed prominently
   - Color-coded availability status
   - "Reserve Slot" button (disabled if fully booked)

4. **Filtering & Sorting**
   - Filter by max distance (km)
   - Sort by: Distance, Price, Availability, Name
   - Filter by status (All/Approved only)

## Distance Calculation Example

```
User Location: 18.5204° N, 73.8567° E (Pune, India)
Station Location: 18.5300° N, 73.8500° E

Distance Calculation:
- Δlat = 0.0096°
- Δlon = 0.0067°
- Distance ≈ 1.2 km
```

## API Endpoints

### GET /getPumps
Returns all CNG stations with:
- Station ID, Name, Address, City
- Latitude, Longitude
- Price per kg
- Status

### GET /getStationAvailability
Returns slot availability for stations:
- Station ID
- Date
- Total slots (24 per day)
- Booked slots
- Available slots

## Sorting Options

1. **By Distance (Nearest First)** - Default when location available
   - Ascending order
   - Shows distance in km

2. **By Price (Lowest First)**
   - Ascending order
   - Cheapest stations first

3. **By Availability (Most Slots First)**
   - Descending order
   - Stations with most available slots first

4. **By Name (Alphabetical)**
   - A-Z order

## Visual Indicators

### Distance Display
- **With Location**: Shows actual distance (e.g., "2.5 km")
- **Without Location**: Shows "N/A"

### Availability Status
- **Green**: Available slots (normal)
- **Orange**: Limited slots (≤5 available)
- **Red**: Fully booked (0 available)

### Station Cards
- Hover effect with green border
- Smooth transitions
- Responsive grid layout

## Error Handling

1. **Location Denied**: Shows alert, allows "Show All Stations"
2. **Location Unavailable**: Falls back to showing all stations
3. **API Errors**: Shows error message, allows retry
4. **No Stations Found**: Shows "No stations found" message

## Performance Considerations

- **Parallel API Calls**: Stations and availability fetched simultaneously
- **Client-Side Sorting**: Fast sorting without server round-trips
- **Caching**: Station data cached until page refresh
- **Lazy Loading**: Availability loaded on demand

## Future Enhancements

1. **Route Calculation**: Show driving distance/time
2. **Traffic-Aware Sorting**: Consider traffic conditions
3. **Favorite Stations**: Save frequently used stations
4. **Push Notifications**: Alert when nearby station has slots
5. **Offline Mode**: Cache stations for offline viewing

## Testing

### Test Cases:
1. ✅ Location granted → Stations sorted by distance
2. ✅ Location denied → All stations shown
3. ✅ Distance calculation accuracy
4. ✅ Availability display correct
5. ✅ Sorting works for all options
6. ✅ Filtering by distance works
7. ✅ Fully booked stations show correctly

## Files Modified

1. **StationAvailabilityServlet.java** (NEW)
   - Servlet to fetch slot availability

2. **ViewAllStations.jsp**
   - Enhanced with GPS location
   - Distance calculation
   - Auto-sorting by distance
   - Availability display

3. **web.xml**
   - Added StationAvailabilityServlet mapping
