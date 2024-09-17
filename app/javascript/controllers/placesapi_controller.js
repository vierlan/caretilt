// app/javascript/controllers/showplacesmap_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { careHomes: Array, markerUrl: String }

  connect() {
    console.log("Stimulus showplacesmap controller connected");
    this.initMap();
    this.initAutocomplete(); // Initialize the autocomplete
  }

  initMap() {
    const careHomes = this.careHomesValue;
    const markerUrl = this.markerUrlValue;

    // Create the map with a default center
    this.map = new google.maps.Map(this.element.querySelector('#map'), {
      zoom: 6,
      center: { lat: 51.5074, lng: -0.1278 }, // Default to London
    });

    // Create a LatLngBounds object to manage the map's viewport
    this.bounds = new google.maps.LatLngBounds();

    // Add markers for each care home
    careHomes.forEach((home) => {
      const lat = parseFloat(home.latitude);
      const lng = parseFloat(home.longitude);

      if (!isNaN(lat) && !isNaN(lng)) {
        const position = { lat, lng };
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
      }
    });

    // Adjust the map to fit the markers
    this.map.fitBounds(this.bounds, { padding: 150 });
  }

  initAutocomplete() {
    // Get the search box input element
    const input = this.element.querySelector('#search-box');

    // Create the autocomplete object and associate it with the input element
    const autocomplete = new google.maps.places.Autocomplete(input);

    // Bias the results to the map's viewport
    autocomplete.bindTo('bounds', this.map);

    // Add listener for place changed event
    autocomplete.addListener('place_changed', () => {
      const place = autocomplete.getPlace();

      if (!place.geometry) {
        console.error("No details available for the input: '" + place.name + "'");
        return;
      }

      // If the place has a geometry, then center the map and adjust zoom
      if (place.geometry.viewport) {
        this.map.fitBounds(place.geometry.viewport);
      } else {
        this.map.setCenter(place.geometry.location);
        this.map.setZoom(12); // Adjust zoom level as needed
      }
    });
  }
}
