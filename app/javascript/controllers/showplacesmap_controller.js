// app/javascript/controllers/showplacesmap_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { careHomes: Array, markerUrl: String }

  connect() {
    console.log("Stimulus showplacesmap controller connected");
    this.initMap();
  }

  initMap() {
    this.map = new google.maps.Map(this.element.querySelector('#map'), {
      zoom: 6,
      center: { lat: 51.5074, lng: -0.1278 }, // Default to London
    });

    this.bounds = new google.maps.LatLngBounds();
    this.markers = []; // Store markers for later use
    this.addMarkers(this.careHomesValue); // Add markers to the map
  }

  addMarkers(careHomes) {
    const markerUrl = this.markerUrlValue;

    this.clearMarkers(); // Clear any existing markers
    careHomes.forEach((home) => {
      const position = { lat: parseFloat(home.latitude), lng: parseFloat(home.longitude) };
      if (!isNaN(position.lat) && !isNaN(position.lng)) {
        this.bounds.extend(position);
        
        const marker = new google.maps.Marker({
          position: position,
          map: this.map,
          title: home.name,
          icon: {
            url: markerUrl,
            scaledSize: new google.maps.Size(100, 100),
          },
          animation: google.maps.Animation.DROP
        });

        const infoWindow = new google.maps.InfoWindow({
          content: `<div><strong>${home.name}</strong></div>`,
        });

        marker.addListener('click', () => {
          infoWindow.open(this.map, marker);
        });

        this.markers.push(marker);
      }
    });

    // Adjust the map to fit the markers
    this.map.fitBounds(this.bounds, { padding: 150 });
  }

  clearMarkers() {
    // Remove all markers from the map
    this.markers.forEach(marker => marker.setMap(null));
    this.markers = [];
    this.bounds = new google.maps.LatLngBounds(); // Reset bounds
  }
}
