// app/javascript/controllers/showplacesmap_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { careHomes: Array, markerUrl: String }

  connect() {
    console.log("Stimulus showplacesmap controller connected");
    this.initMap();
  }

  initMap() {
      const careHomes = this.careHomesValue;
      const markerUrl = this.markerUrlValue; // Get the marker URL

      // Create the map with a default center
      const map = new google.maps.Map(this.element.querySelector('#map'), {
          zoom: 6, // Initial zoom level; will be adjusted
      });

      // Create a LatLngBounds object to manage the map's viewport
      const bounds = new google.maps.LatLngBounds();

      // Track whether any markers were added
      let markersAdded = false;

      // Add markers for each care home
      careHomes.forEach((home) => {
          const lat = parseFloat(home.latitude);
          const lng = parseFloat(home.longitude);

          // Validate latitude and longitude
          if (!isNaN(lat) && !isNaN(lng)) {
              const position = { lat, lng };

              // Extend the bounds to include this marker's location
              bounds.extend(position);
              markersAdded = true;

              const marker = new google.maps.Marker({
                  position: position,
                  map: map,
                  title: home.name, // Tooltip when you hover over the marker
                  // Use the custom marker icon
                  icon: {
                      url: markerUrl, // Use the local image passed from the view
                      scaledSize: new google.maps.Size(100, 100), // Adjust the size as needed
                  },
                  animation: google.maps.Animation.DROP
              });

              // Optionally, add an info window to each marker
              const infoWindow = new google.maps.InfoWindow({
                  content: `<div><strong>${home.name}</strong></div>`,
              });

              // Show the info window when the marker is clicked
              marker.addListener('click', () => {
                  infoWindow.open(map, marker);
              });
          }
      });

      // Adjust map zoom and center only if markers were added
      if (markersAdded) {
          // Auto-zoom and center the map to fit all markers within bounds
          map.fitBounds(bounds, { padding: 150 });

          // If there's only one marker or the markers are very close, manually set a minimum zoom level
          const listener = google.maps.event.addListenerOnce(map, 'bounds_changed', () => {
              const MAX_ZOOM = 15; // Set a maximum zoom level (e.g., 15)

              if (map.getZoom() > MAX_ZOOM) {
                  map.setZoom(MAX_ZOOM);
              }
          });
      } else {
          // If no valid markers, set a default view
          map.setCenter({ lat: 0, lng: 0 });
          map.setZoom(2); // Default world view
      }
  }

}
