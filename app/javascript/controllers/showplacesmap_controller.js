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

    // Add markers for each care home
    careHomes.forEach((home) => {
      const position = { lat: parseFloat(home.latitude), lng: parseFloat(home.longitude) };

      // Extend the bounds to include this marker's location
      bounds.extend(position);
      console.log(position)

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
    });

    // Auto-zoom and center the map to fit all markers within bounds
    map.fitBounds(bounds, {padding: 150});
  }
}
