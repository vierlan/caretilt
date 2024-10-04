// app/javascript/controllers/showplacesmap_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  // Define two static values: careHomes for multiple homes (index page) and careHome for a single home (show page)
  static values = { careHomes: Array, careHome: Object, markerUrl: String }

  connect() {
    console.log("Stimulus showplacesmap controller connected");

    // Initialize the map based on whether we're dealing with a single care home (show page) or multiple care homes (index page)
    if (this.hasCareHomesValue) {
      // If multiple care homes (index page)
      this.initMapForMultiple();
    } else if (this.hasCareHomeValue) {
      // If a single care home (show page)
      this.initMapForSingle();
    }
  }

  // Initialize the map for multiple care homes (index page)
  initMapForMultiple() {
    this.map = new google.maps.Map(this.element.querySelector('#map'), {
      zoom: 7, // Default zoom level for a broader view
      center: { lat: 51.5074, lng: -0.1278 }, // Default center set to London
    });

    this.bounds = new google.maps.LatLngBounds(); // Create a LatLngBounds object to automatically fit markers
    this.markers = []; // Array to store markers
    this.addMarkers(this.careHomesValue); // Add markers for multiple care homes
  }

  // Initialize the map for a single care home (show page)
  initMapForSingle() {
    const careHome = this.careHomeValue;

    // Initialize map centered around the single care home
    this.map = new google.maps.Map(this.element.querySelector('#map'), {
      zoom: 15, // Closer zoom for a single care home
      center: { lat: parseFloat(careHome.latitude), lng: parseFloat(careHome.longitude) }, // Center on the care home's location
    });

    // Add a single marker for the care home
    this.addMarker(careHome);
  }

  // Add multiple markers for the care homes (used in index page)
  addMarkers(careHomes) {
    const markerUrl = this.markerUrlValue;

    this.clearMarkers(); // Clear any existing markers
    careHomes.forEach((home) => {
      const position = { lat: parseFloat(home.latitude), lng: parseFloat(home.longitude) };
      if (!isNaN(position.lat) && !isNaN(position.lng)) {
        this.bounds.extend(position); // Extend the bounds to include this marker
        
        const marker = new google.maps.Marker({
          position: position,
          map: this.map,
          title: home.name,
          icon: {
            url: markerUrl,
            scaledSize: new google.maps.Size(100, 100), // Custom icon size
          },
          animation: google.maps.Animation.DROP
        });

        const infoWindow = new google.maps.InfoWindow({
          content: `<div><strong>${home.name}</strong></div>`, // Info window content for each marker
        });

        marker.addListener('click', () => {
          infoWindow.open(this.map, marker); // Open info window when marker is clicked
        });

        this.markers.push(marker); // Add the marker to the array of markers
      }
    });

    // Adjust the map based on the number of markers
    if (careHomes.length === 1) {
      // For one marker, center the map on it with a closer zoom
      this.map.setCenter(this.bounds.getCenter());
      this.map.setZoom(17);
    } else if (careHomes.length > 1) {
      // For multiple markers, fit all markers in the visible map area
      this.map.fitBounds(this.bounds, { padding: 150 });
    }
  }

  // Add a single marker (used in show page)
  addMarker(careHome) {
    const markerUrl = this.markerUrlValue;
    const position = { lat: parseFloat(careHome.latitude), lng: parseFloat(careHome.longitude) };

    if (!isNaN(position.lat) && !isNaN(position.lng)) {
      const marker = new google.maps.Marker({
        position: position,
        map: this.map,
        title: careHome.name,
        icon: {
          url: markerUrl,
          scaledSize: new google.maps.Size(100, 100), // Custom icon size
        },
        animation: google.maps.Animation.DROP
      });

      const infoWindow = new google.maps.InfoWindow({
        content: `<div><strong>${careHome.name}</strong></div>`, // Info window content for the marker
      });

      marker.addListener('click', () => {
        infoWindow.open(this.map, marker); // Open info window when marker is clicked
      });
    }
  }

  // Clear all markers from the map
  clearMarkers() {
    this.markers.forEach(marker => marker.setMap(null)); // Remove each marker from the map
    this.markers = []; // Reset the markers array
    this.bounds = new google.maps.LatLngBounds(); // Reset bounds for the map
  }
}
