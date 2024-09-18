import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { careHomes: Array, markerUrl: String }

  connect() {
    console.log("Stimulus showplacesmap controller connected");
    this.initMap();
    this.initAutocomplete(); // Initialize autocomplete
    this.initDropdownFilter(); // Initialize the local authority dropdown filter
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

  initAutocomplete() {
    const input = this.element.querySelector('#search-box');
    const autocomplete = new google.maps.places.Autocomplete(input);

    autocomplete.addListener('place_changed', () => {
      const place = autocomplete.getPlace();
      if (place.geometry) {
        this.map.fitBounds(place.geometry.viewport || new google.maps.LatLngBounds());
        this.map.setCenter(place.geometry.location);
        this.map.setZoom(12);
      } else {
        console.error("No details available for the input: '" + place.name + "'");
      }
    });
  }

  initDropdownFilter() {
    const dropdown = this.element.querySelector('#local-authority-dropdown');
    dropdown.addEventListener('change', (event) => {
      const selectedAuthority = event.target.value;
      this.filterMarkers(selectedAuthority);
    });
  }

  addMarkers(careHomes) {
    const markerUrl = this.markerUrlValue;
  
    this.clearMarkers(); // Clear any existing markers
  
    if (careHomes.length === 0) {
      // If no care homes match the filter, reset the map's center and zoom
      this.map.setCenter({ lat: 51.5074, lng: -0.1278 }); // Default to London
      this.map.setZoom(6);
      return;
    }
  
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
    if (careHomes.length === 1) {
      // If there's only one care home, set a default zoom level and center the map
      const singleHome = careHomes[0];
      const singlePosition = { lat: parseFloat(singleHome.latitude), lng: parseFloat(singleHome.longitude) };
  
      this.map.setCenter(singlePosition);
      this.map.setZoom(15); // Adjust the zoom level as desired
    } else {
      // Auto-zoom and center the map to fit all markers within bounds
      this.map.fitBounds(this.bounds, { padding: 150 });
    }
  }
  

  filterMarkers(selectedAuthority) {
    // Filter care homes by selected local authority
    const filteredHomes = selectedAuthority
      ? this.careHomesValue.filter(home => home.local_authority_name === selectedAuthority)
      : this.careHomesValue; // Show all if no filter is selected

    this.addMarkers(filteredHomes);
  }

  clearMarkers() {
    // Remove all markers from the map
    this.markers.forEach(marker => marker.setMap(null));
    this.markers = [];
    this.bounds = new google.maps.LatLngBounds(); // Reset bounds
  }
}
