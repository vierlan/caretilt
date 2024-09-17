import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { careHomes: Array, markerUrl: String, apiKey: String } // Added apiKey to static values

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

    // Fit map to markers
    this.map.fitBounds(this.bounds, { padding: 150 });
  }

  initAutocomplete() {
    const input = this.element.querySelector('#search-box');
    const autocomplete = new google.maps.places.Autocomplete(input);
    autocomplete.bindTo('bounds', this.map);

    autocomplete.addListener('place_changed', () => {
      const place = autocomplete.getPlace();

      if (!place.geometry) {
        console.error("No details available for the input: '" + place.name + "'");
        return;
      }

      if (place.geometry.viewport) {
        this.map.fitBounds(place.geometry.viewport);
      } else {
        this.map.setCenter(place.geometry.location);
        this.map.setZoom(12);
      }

      // Call the Geocoding API to get the polygon coordinates
      this.getPolygonCoordinates(place.name);
    });
  }

  getPolygonCoordinates(regionName) {
    const geocodeUrl = `https://maps.googleapis.com/maps/api/geocode/json?address=${encodeURIComponent(regionName)}&key=${this.apiKeyValue}`; // Use this.apiKeyValue

    fetch(geocodeUrl)
      .then(response => response.json())
      .then(data => {
        if (data.status === "OK") {
          const geometry = data.results[0].geometry;
          // Use viewport as a fallback if bounds are not available
          const bounds = geometry.bounds || geometry.viewport;

          if (bounds) {
            this.drawPolygon(bounds);
          } else {
            console.error("No polygon data available for this region.");
          }
        } else {
          console.error("Geocode was not successful for the following reason: " + data.status);
        }
      })
      .catch(error => console.error("Geocode error:", error));
  }

  drawPolygon(bounds) {
    const ne = bounds.northeast;
    const sw = bounds.southwest;

    // Define the LatLng coordinates for the polygon's path (rectangle from bounds)
    const polygonCoords = [
      { lat: ne.lat, lng: ne.lng },
      { lat: ne.lat, lng: sw.lng },
      { lat: sw.lat, lng: sw.lng },
      { lat: sw.lat, lng: ne.lng },
    ];

    // Create the polygon
    const polygon = new google.maps.Polygon({
      paths: polygonCoords,
      strokeColor: '#FF0000',
      strokeOpacity: 0.8,
      strokeWeight: 2,
      fillColor: '#FF0000',
      fillOpacity: 0.35,
    });

    // Set the polygon on the map
    polygon.setMap(this.map);

    // Optionally, adjust the bounds to fit the polygon
    polygonCoords.forEach(coord => {
      this.bounds.extend(coord);
    });
    this.map.fitBounds(this.bounds, { padding: 50 });
  }
}
