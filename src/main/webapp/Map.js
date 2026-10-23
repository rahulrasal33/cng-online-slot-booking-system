
// Haversine formula
function getDistance(lat1, lon1, lat2, lon2) {
  const R = 6371; // km
  const dLat = (lat2 - lat1) * Math.PI / 180;
  const dLon = (lon2 - lon1) * Math.PI / 180;
  const a = 
    Math.sin(dLat/2) * Math.sin(dLat/2) +
    Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) *
    Math.sin(dLon/2) * Math.sin(dLon/2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
  return R * c;
}

// Get user location
navigator.geolocation.getCurrentPosition(
  (pos) => {
    const userLat = pos.coords.latitude;
    const userLng = pos.coords.longitude;

    console.log("Your location:", userLat, userLng);

    // Loop through all station cards
    document.querySelectorAll(".station-card").forEach(card => {
      const lat = Number(card.dataset.lat);
      const lng = Number(card.dataset.lng);

      if (Number.isFinite(lat) && Number.isFinite(lng)
          && lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180
          && !(lat === 0 && lng === 0)) {
        const dist = getDistance(userLat, userLng, lat, lng).toFixed(1);
        const distEl = card.querySelector(".distance");
        if (distEl) {
          distEl.innerHTML = `<i class="fa fa-road"></i> ~${dist} km direct from you`;
          distEl.title = "Straight-line distance. Google Maps shows the driving route distance.";
        }
        const directionsLink = card.querySelector('a[href*="google.com/maps"]');
        if (directionsLink) {
          const destination = encodeURIComponent(`${lat},${lng}`);
          const origin = encodeURIComponent(`${userLat},${userLng}`);
          directionsLink.href = `https://www.google.com/maps/dir/?api=1&origin=${origin}&destination=${destination}&travelmode=driving`;
        }
      }
    });
  },
  (err) => {
    console.error("Location error:", err);
    alert("Unable to get your location. Please enable GPS or location access.");
  }
);
