<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1" isELIgnored="true" %>
  <%@ page import="java.sql.*" %>
    <%@ page import="com.DbConnection.*" %>
      <!DOCTYPE html>
      <html lang="en">

      <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>All CNG Stations Near You</title>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
        <style>
          * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
          }

          body {
            font-family: 'Segoe UI', sans-serif;
            background: #0d1117;
            color: #e0e0e0;
            padding: 20px;
          }

          .header {
            text-align: center;
            margin-bottom: 30px;
            padding: 20px;
          }

          .header h1 {
            color: #00ff66;
            font-size: 2.5em;
            margin-bottom: 10px;
            text-shadow: 0 0 15px #00ff66;
          }

          .header p {
            color: #aaa;
            font-size: 1.1em;
          }

          .controls {
            display: flex;
            justify-content: center;
            gap: 15px;
            margin-bottom: 30px;
            flex-wrap: wrap;
          }

          .controls button {
            padding: 12px 24px;
            background: #00ff66;
            color: #111;
            border: none;
            border-radius: 8px;
            cursor: pointer;
            font-size: 16px;
            font-weight: bold;
            transition: all 0.3s ease;
          }

          .controls button:hover {
            background: #00cc55;
            box-shadow: 0 0 20px rgba(0, 255, 102, 0.5);
          }

          .controls button:disabled {
            background: #555;
            cursor: not-allowed;
            opacity: 0.6;
          }

          .filter-controls {
            display: flex;
            justify-content: center;
            gap: 15px;
            margin-bottom: 20px;
            flex-wrap: wrap;
          }

          .filter-controls select,
          .filter-controls input {
            padding: 10px 15px;
            background: #1f2937;
            color: #fff;
            border: 2px solid #333;
            border-radius: 6px;
            font-size: 14px;
          }

          .filter-controls select:focus,
          .filter-controls input:focus {
            border-color: #00ff66;
            outline: none;
          }

          .location-info {
            text-align: center;
            margin-bottom: 20px;
            padding: 15px;
            background: #1f2937;
            border-radius: 8px;
            display: none;
          }

          .location-info.active {
            display: block;
          }

          .location-attribution {
            color: #cbd5e1;
            font-size: 12px;
          }

          .stations-container {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(350px, 1fr));
            gap: 20px;
            max-width: 1400px;
            margin: 0 auto;
          }

          .station-card {
            background: #1f2937;
            border-radius: 12px;
            padding: 20px;
            border: 2px solid #333;
            transition: all 0.3s ease;
            position: relative;
          }

          .station-card:hover {
            border-color: #00ff66;
            box-shadow: 0 0 20px rgba(0, 255, 102, 0.3);
            transform: translateY(-5px);
          }

          .station-header {
            display: flex;
            justify-content: space-between;
            align-items: start;
            margin-bottom: 15px;
          }

          .station-header h3 {
            color: #00ff66;
            font-size: 1.3em;
            flex: 1;
          }

          .price {
            color: #00ff66;
            font-size: 1.2em;
            font-weight: bold;
          }

          .address {
            color: #aaa;
            margin-bottom: 15px;
            display: flex;
            align-items: center;
            gap: 8px;
          }

          .station-info {
            display: flex;
            justify-content: space-between;
            margin-bottom: 15px;
            flex-wrap: wrap;
            gap: 10px;
          }

          .distance {
            color: #00ff66;
            font-weight: bold;
          }

          .rating {
            color: #ffd700;
          }

          .status {
            display: flex;
            justify-content: space-between;
            margin-bottom: 15px;
            padding: 10px;
            background: #111827;
            border-radius: 6px;
          }

          .open {
            color: #00ff66;
            display: flex;
            align-items: center;
            gap: 5px;
          }

          .open i {
            font-size: 10px;
          }

          .tags {
            display: flex;
            flex-wrap: wrap;
            gap: 8px;
            margin-bottom: 15px;
          }

          .tags span {
            background: #111827;
            padding: 5px 12px;
            border-radius: 20px;
            font-size: 0.85em;
            color: #aaa;
          }

          .actions {
            display: flex;
            gap: 10px;
          }

          .actions button {
            flex: 1;
            padding: 10px;
            border: none;
            border-radius: 6px;
            cursor: pointer;
            font-weight: bold;
            transition: all 0.3s ease;
          }

          .reserve-btn {
            background: #00ff66;
            color: #111;
          }

          .reserve-btn:hover {
            background: #00cc55;
          }

          .map-btn {
            background: #374151;
            color: #fff;
          }

          .map-btn:hover {
            background: #555;
          }

          .loading {
            text-align: center;
            padding: 40px;
            color: #00ff66;
            font-size: 1.2em;
          }

          .no-stations {
            text-align: center;
            padding: 40px;
            color: #aaa;
            font-size: 1.1em;
          }

          .sort-info {
            text-align: center;
            margin-bottom: 20px;
            color: #aaa;
            font-size: 0.9em;
          }

          .sort-info strong {
            color: #00ff66;
            font-weight: bold;
          }

          .station-card .distance i.fa-trophy {
            color: #ffd700;
            margin-right: 5px;
          }

          .slots-available {
            color: #00ff66;
            font-weight: bold;
          }

          .slots-available.limited {
            color: #ffaa00;
          }

          .slots-available.full {
            color: #dc2626;
          }
        </style>
      </head>

      <body>
        <div class="header">
          <h1><span style="color: #00ff66;">CNG Stations</span> Near You</h1>
          <p>Find the most convenient CNG station with real-time availability and competitive prices</p>
        </div>

        <div class="controls">
          <button id="getLocationBtn" onclick="getUserLocation()">
            <i class="fas fa-map-marker-alt"></i> Use My Location
          </button>
          <button onclick="showAllStations()">
            <i class="fas fa-list"></i> Show All Stations
          </button>
          <button id="retryBtn" style="display:none;">
            <i class="fas fa-rotate-right"></i> Retry
          </button>
        </div>

        <div class="location-info" id="locationInfo">
          <p><i class="fas fa-info-circle"></i> <span id="locationText"></span></p>
          <small class="location-attribution">Place names by <a href="https://www.openstreetmap.org/copyright" target="_blank" rel="noopener noreferrer">OpenStreetMap contributors</a></small>
        </div>

        <div class="filter-controls">
          <select id="sortBy" onchange="sortStations()">
            <option value="distance">Sort by Distance (Nearest First)</option>
            <option value="price">Sort by Price (Lowest First)</option>
            <option value="availability">Sort by Availability (Most Slots First)</option>
            <option value="name">Sort by Name</option>
          </select>
          <input type="number" id="maxDistance" placeholder="Max Distance (km)" value="10" min="5" max="10"
            onchange="filterByDistance()">
          <select id="statusFilter" onchange="filterStations()">
            <option value="all">All Status</option>
            <option value="APPROVED">Approved Only</option>
          </select>
        </div>

        <div class="sort-info" id="sortInfo"></div>

        <div class="stations-container" id="stationsContainer">
          <div class="loading">Loading stations...</div>
        </div>

        <script>
          let userLat = null;
          let userLng = null;
          let allStations = [];
          let filteredStations = [];
          const locationNameCache = new Map();

          function updateLocationText(latitude, longitude) {
            const locationText = document.getElementById("locationText");
            const cacheKey = latitude.toFixed(2) + "," + longitude.toFixed(2);
            locationText.textContent = "Finding your area name... Stations are being sorted by distance.";

            if (locationNameCache.has(cacheKey)) {
              locationText.textContent = "Near " + locationNameCache.get(cacheKey)
                + " - Stations sorted by distance (nearest first)";
              return;
            }

            const reverseGeocodeUrl = "https://nominatim.openstreetmap.org/reverse?format=jsonv2&zoom=16&lat="
              + encodeURIComponent(latitude) + "&lon=" + encodeURIComponent(longitude);
            fetch(reverseGeocodeUrl, { headers: { Accept: "application/json" } })
              .then(response => {
                if (!response.ok) {
                  throw new Error("Place-name lookup failed with HTTP " + response.status);
                }
                return response.json();
              })
              .then(result => {
                const address = result.address || {};
                const neighbourhood = address.neighbourhood || address.suburb || address.city_district;
                const locality = address.city || address.town || address.village
                  || address.municipality || address.county;
                const placeName = [neighbourhood, locality, address.state]
                  .filter((part, index, parts) => part && parts.indexOf(part) === index)
                  .join(", ") || result.name || "";

                if (!placeName) {
                  throw new Error("No nearby place name was returned.");
                }

                locationNameCache.set(cacheKey, placeName);
                locationText.textContent = "Near " + placeName
                  + " - Stations sorted by distance (nearest first)";
              })
              .catch(error => {
                console.warn("Could not determine the current place name:", error);
                locationText.textContent =
                  "Nearby place name unavailable - Stations sorted by distance (nearest first)";
              });
          }

          // Get user's location
          function getUserLocation() {
            const btn = document.getElementById("getLocationBtn");
            btn.disabled = true;
            btn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Getting Location...';

            if (navigator.geolocation) {
              navigator.geolocation.getCurrentPosition(
                (position) => {
                  userLat = position.coords.latitude;
                  userLng = position.coords.longitude;

                  document.getElementById("locationInfo").classList.add("active");
                  updateLocationText(userLat, userLng);

                  btn.disabled = false;
                  btn.innerHTML = '<i class="fas fa-map-marker-alt"></i> Use My Location';

                  // Reload stations with location - will auto-sort by distance
                  loadStations();
                },
                (error) => {
                  console.error("Geolocation error:", error);
                  let msg = "Unable to get your location. Please enable location services or use 'Show All Stations'.";
                  if (error.code === error.PERMISSION_DENIED) {
                    msg = "Location permission was denied. Please allow location access in your browser settings or use 'Show All Stations'.";
                  } else if (location.protocol !== 'https:' && location.hostname !== 'localhost') {
                    msg = "Location access is blocked on insecure connections. Please use HTTPS or localhost, or use 'Show All Stations'.";
                  }
                  alert(msg);
                  btn.disabled = false;
                  btn.innerHTML = '<i class="fas fa-map-marker-alt"></i> Use My Location';
                  // Fallback: load stations without location
                  loadStations();
                }
              );
            } else {
              console.log("Location not available");
              btn.disabled = false;
              btn.innerHTML = '<i class="fas fa-map-marker-alt"></i> Use My Location';
            }
          }

          // Show all stations without location
          function showAllStations() {
            userLat = null;
            userLng = null;
            document.getElementById("locationInfo").classList.remove("active");
            // Reset sort to name when location is cleared
            document.getElementById("sortBy").value = "name";
            loadStations();
          }

          // Calculate distance between two coordinates (Haversine formula)
          function calculateDistance(lat1, lon1, lat2, lon2) {
            const R = 6371; // Earth's radius in km
            const dLat = (lat2 - lat1) * Math.PI / 180;
            const dLon = (lon2 - lon1) * Math.PI / 180;
            const a =
              Math.sin(dLat / 2) * Math.sin(dLat / 2) +
              Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) *
              Math.sin(dLon / 2) * Math.sin(dLon / 2);
            const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
            return R * c;
          }

          // Load stations from server
          function loadStations() {
            const container = document.getElementById("stationsContainer");
            const retryBtn = document.getElementById("retryBtn");
            container.innerHTML = '<div class="loading">Loading stations...</div>';
            if (retryBtn) retryBtn.style.display = "none";

            // Get today's date in YYYY-MM-DD format
            const today = new Date().toISOString().split('T')[0];

            // Build URLs, passing location to backend (for logging / future filtering)
            const pumpsUrl = (userLat != null && userLng != null)
              ? "getPumps?lat=" + encodeURIComponent(userLat) + "&lng=" + encodeURIComponent(userLng)
              : "getPumps";
            const availabilityUrl = "getStationAvailability?date=" + today;

            function fetchJson(url, label) {
              return fetch(url).then(async (r) => {
                if (!r.ok) {
                  const text = await r.text().catch(() => "");
                  throw new Error(label + " failed (" + r.status + ") " + (text || ""));
                }
                const data = await r.json().catch((e) => {
                  throw new Error(label + " returned invalid JSON: " + e.message);
                });
                if (data && data.error) {
                  throw new Error(label + " error: " + data.error);
                }
                if (!Array.isArray(data)) {
                  throw new Error(label + " returned unexpected format");
                }
                return data;
              });
            }

            Promise.all([
              fetchJson(pumpsUrl, "Stations API"),
              fetchJson(availabilityUrl, "Availability API")
            ])
              .then(([stationsData, availabilityData]) => {
                allStations = stationsData;

                // Create availability map for quick lookup
                const availabilityMap = {};
                availabilityData.forEach(avail => {
                  availabilityMap[avail.stationId] = avail;
                });

                // Calculate distances if user location is available
                if (userLat !== null && userLng !== null) {
                  allStations.forEach(station => {
                    if (station.lat !== null && station.lat !== undefined
                        && station.lng !== null && station.lng !== undefined
                        && Number.isFinite(Number(station.lat)) && Number.isFinite(Number(station.lng))
                        && !(Number(station.lat) === 0 && Number(station.lng) === 0)) {
                      station.distance = calculateDistance(userLat, userLng, station.lat, station.lng);
                    } else {
                      station.distance = null;
                    }

                    // Add availability data
                    if (availabilityMap[station.id]) {
                      station.availableSlots = availabilityMap[station.id].availableSlots;
                      station.bookedSlots = availabilityMap[station.id].bookedSlots;
                      station.totalSlots = availabilityMap[station.id].totalSlots;
                    } else {
                      station.availableSlots = 24; // Default if not found
                      station.bookedSlots = 0;
                      station.totalSlots = 24;
                    }
                  });

                  // Auto-sort by distance (nearest first) when location is available
                  allStations.sort((a, b) => {
                    const distA = a.distance !== null ? a.distance : Infinity;
                    const distB = b.distance !== null ? b.distance : Infinity;
                    return distA - distB;
                  });

                  // Set sort dropdown to distance
                  document.getElementById("sortBy").value = "distance";
                } else {
                  // No location - add availability but don't sort
                  allStations.forEach(station => {
                    if (availabilityMap[station.id]) {
                      station.availableSlots = availabilityMap[station.id].availableSlots;
                      station.bookedSlots = availabilityMap[station.id].bookedSlots;
                      station.totalSlots = availabilityMap[station.id].totalSlots;
                    } else {
                      station.availableSlots = 24;
                      station.bookedSlots = 0;
                      station.totalSlots = 24;
                    }
                  });
                }

                filterStations();
              })
              .catch(error => {
                console.error("Error loading stations:", error);
                const safeMessage = error && error.message ? error.message : "Unknown error";
                container.innerHTML =
                  '<div class="no-stations">Unable to load stations.<br/>' +
                  'Details: ' + safeMessage.replace(/</g, "&lt;") +
                  '<br/>Please check your internet connection or try again.</div>';
                if (retryBtn) {
                  retryBtn.onclick = () => loadStations();
                  retryBtn.style.display = "inline-flex";
                }
              });
          }

          // Filter stations
          function filterStations() {
            filteredStations = [...allStations];

            // Filter by status
            const statusFilter = document.getElementById("statusFilter").value;
            if (statusFilter !== "all") {
              filteredStations = filteredStations.filter(station => {
                return station.status === statusFilter;
              });
            }

            // Filter by distance
            const maxDistance = parseFloat(document.getElementById("maxDistance").value) || 500;
            if (userLat !== null && userLng !== null) {
              filteredStations = filteredStations.filter(station => {
                return station.distance !== null && station.distance <= maxDistance;
              });
            }

            // Apply sorting (preserves distance sort if location available)
            sortStations();
          }

          // Sort stations
          function sortStations() {
            const sortBy = document.getElementById("sortBy").value;

            // If location is available and sort is not explicitly set, default to distance
            if (userLat !== null && userLng !== null && (!sortBy || sortBy === "distance")) {
              filteredStations.sort((a, b) => {
                const distA = a.distance !== null ? a.distance : Infinity;
                const distB = b.distance !== null ? b.distance : Infinity;
                return distA - distB; // Ascending order (nearest first)
              });
            } else {
              filteredStations.sort((a, b) => {
                if (sortBy === "distance") {
                  if (userLat === null || userLng === null) {
                    // If no location but distance selected, show message
                    return 0;
                  }
                  const distA = a.distance !== null ? a.distance : Infinity;
                  const distB = b.distance !== null ? b.distance : Infinity;
                  return distA - distB; // Ascending order (nearest first)
                } else if (sortBy === "price") {
                  const priceA = parseFloat(a.price_per_kg) || Infinity;
                  const priceB = parseFloat(b.price_per_kg) || Infinity;
                  return priceA - priceB; // Ascending order (cheapest first)
                } else if (sortBy === "name") {
                  return (a.name || "").localeCompare(b.name || "");
                } else if (sortBy === "availability") {
                  const availA = a.availableSlots || 0;
                  const availB = b.availableSlots || 0;
                  return availB - availA; // Descending order (most available first)
                }
                return 0;
              });
            }

            renderStations();
          }

          // Render stations
          function renderStations() {
            const container = document.getElementById("stationsContainer");

            if (filteredStations.length === 0) {
              container.innerHTML = '<div class="no-stations">No stations found matching your criteria.</div>';
              document.getElementById("sortInfo").textContent = "";
              return;
            }

            let html = "";
            filteredStations.forEach(station => {
              const distance = station.distance !== null && station.distance !== undefined
                ? "~" + station.distance.toFixed(2) + " km direct from you"
                  : (userLat !== null && userLng !== null ? "Location unavailable" : "Enable location for distance");

              const availableSlots = station.availableSlots !== undefined ? station.availableSlots : 24;
              const bookedSlots = station.bookedSlots !== undefined ? station.bookedSlots : 0;
              const totalSlots = station.totalSlots !== undefined ? station.totalSlots : 24;
              const hasCoordinates = station.lat !== null && station.lat !== undefined
                && station.lng !== null && station.lng !== undefined
                && Number.isFinite(Number(station.lat)) && Number.isFinite(Number(station.lng))
                && Number(station.lat) >= -90 && Number(station.lat) <= 90
                && Number(station.lng) >= -180 && Number(station.lng) <= 180
                && !(Number(station.lat) === 0 && Number(station.lng) === 0);
              const directionsUrl = hasCoordinates
                ? "https://www.google.com/maps/dir/?api=1&"
                  + (userLat !== null && userLng !== null
                    ? "origin=" + encodeURIComponent(userLat + "," + userLng) + "&"
                    : "")
                  + "destination=" + encodeURIComponent(Number(station.lat) + "," + Number(station.lng))
                  + "&travelmode=driving"
                : null;

              // Determine availability status
              let availabilityStatus = "Available";
              let availabilityClass = "available";
              if (availableSlots === 0) {
                availabilityStatus = "Fully Booked";
                availabilityClass = "full";
              } else if (availableSlots <= 5) {
                availabilityStatus = "Limited Slots";
                availabilityClass = "limited";
              }

              html += `
          <div class="station-card">
            <div class="station-header">
              <h3>` + (station.name || "Unnamed Station") + `</h3>
              <span class="price">
                <i class="fa fa-inr"></i>` + (station.price_per_kg || "N/A") + ` <small>/Kg</small>
              </span>
            </div>
            <p class="address">
              <i class="fa fa-map-marker-alt"></i> 
              ` + (station.address || "") + (station.city ? ", " + station.city : "") + `
            </p>
            <div class="station-info">
              <span class="distance" title="Straight-line distance. Google Maps shows the driving route distance.">
                <i class="fa fa-road"></i> ` + distance + `
              </span>
              <span class="rating">
                <i class="fa fa-star"></i> 4.8
              </span>
            </div>
            <div class="status">
              <span class="open">
                <i class="fa fa-circle"></i> Open Now
              </span>
              <span class="slots-available ` + availabilityClass + `">
                <i class="fa fa-calendar-check"></i> 
                ` + availableSlots + ` slots available
                ` + (bookedSlots > 0 ? " (" + bookedSlots + "/" + totalSlots + " booked)" : "") + `
              </span>
            </div>
            <div class="tags">
              <span>24/7 Service</span>
              <span>` + (station.phone || "N/A") + `</span>
              <span>` + (station.city || "") + `</span>
              ` + (station.status === 'APPROVED' ? '<span style="color: #00ff66;">✓ Approved</span>' : '') + `
            </div>
            <div class="actions">
              <a href="SlotBookings.jsp">
                <button class="reserve-btn" ` + (availableSlots === 0 ? 'disabled style="opacity: 0.5; cursor: not-allowed;"' : '') + `>
                  <i class="fa fa-calendar"></i> Reserve Slot
                </button>
              </a>
              ` + (directionsUrl
                ? '<a href="' + directionsUrl + '" target="_blank" rel="noopener noreferrer"><button class="map-btn" type="button"><i class="fa fa-map"></i> Get Directions</button></a>'
                : '<button class="map-btn" type="button" disabled title="This station has no saved map coordinates"><i class="fa fa-map"></i> Location Unavailable</button>') + `
            </div>
          </div>
        `;
            });

            container.innerHTML = html;

            // Update sort info with clear indication of sorting
            const sortBy = document.getElementById("sortBy").value;
            let info = "Showing " + filteredStations.length + " station(s)";
            if (userLat !== null && userLng !== null) {
              if (sortBy === 'distance') {
                info += ` • Sorted by distance (nearest first)`;
                // Highlight nearest station
                const firstCard = container.querySelector('.station-card');
                if (firstCard && filteredStations.length > 0 && filteredStations[0].distance !== null) {
                  firstCard.style.borderColor = '#00ff66';
                  firstCard.style.boxShadow = '0 0 25px rgba(0, 255, 102, 0.5)';
                  const distanceBadge = firstCard.querySelector('.distance');
                  if (distanceBadge) {
                    distanceBadge.innerHTML = "<i class=\"fa fa-trophy\"></i> Nearest: " + filteredStations[0].distance.toFixed(2) + " km";
                    distanceBadge.style.color = '#00ff66';
                    distanceBadge.style.fontWeight = 'bold';
                  }
                }
              } else {
                info += " • Sorted by " + sortBy;
              }
            } else if (sortBy !== 'distance') {
              info += " • Sorted by " + sortBy;
            }
            document.getElementById("sortInfo").textContent = info;
          }

          // Filter by distance
          function filterByDistance() {
            filterStations();
          }

          // Load stations on page load
          window.addEventListener("load", function () {
            // Try to get location automatically on page load (optional)
            // User can also click "Use My Location" button
            if (navigator.geolocation) {
              navigator.geolocation.getCurrentPosition(
                (position) => {
                  userLat = position.coords.latitude;
                  userLng = position.coords.longitude;
                  document.getElementById("locationInfo").classList.add("active");
                  updateLocationText(userLat, userLng);
                  loadStations(); // Will auto-sort by distance
                },
                (error) => {
                  // Location denied or unavailable - load stations without sorting
                  console.log("Location not available on page load:", error);
                  loadStations();
                },
                {
                  enableHighAccuracy: true,
                  timeout: 5000,
                  maximumAge: 0
                }
              );
            } else {
              // Geolocation not supported - load stations normally
              loadStations();
            }
          });
        </script>
      </body>

      </html>