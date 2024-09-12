import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["place", "radiusSlider", "resultsContainer"]

  connect() {
    console.log("Stimulus Places controller connected")
    this.initPlacesAutocomplete()
  }

  initPlacesAutocomplete() {
    const input = this.placeTarget;
    const autocomplete = new google.maps.places.Autocomplete(input);

    // When the user selects an address, place it on the map and log the details
    autocomplete.addListener('place_changed', () => {
      const place = autocomplete.getPlace();
      if (place.geometry) {
        // Log the latitude and longitude
        const lat = place.geometry.location.lat();
        const lng = place.geometry.location.lng();
        console.log(`Latitude: ${lat}, Longitude: ${lng}`);

        // Log the entire place object for debugging
        console.log("Full place object:", place);

        // Extract address components (postcode, region, etc.)
        const addressComponents = this.extractAddressComponents(place);
        console.log("Address Components:", addressComponents);

        // Display the map and address details
        this.displayMapWithLocation(place.geometry.location);
        this.showSelectedAddress(place);
      } else {
        console.error("No geometry available for this place.");
      }
    });
  }

  // Extract important address components like postcode, city, and country
  extractAddressComponents(place) {
    const components = {};
    place.address_components.forEach(component => {
      const types = component.types;
      if (types.includes("postal_code")) {
        components.postcode = component.long_name;
      }
      if (types.includes("locality")) {
        components.city = component.long_name;
      }
      if (types.includes("administrative_area_level_1")) {
        components.region = component.long_name;
      }
      if (types.includes("country")) {
        components.country = component.long_name;
      }
    });
    return components;
  }

  displayMapWithLocation(location) {
    // Initialize the map with the selected location
    const map = new google.maps.Map(document.getElementById('map'), {
      center: location,
      zoom: 15,
    });

    // Place a marker on the selected location
    new google.maps.Marker({
      position: location,
      map: map,
    });
  }

  showSelectedAddress(place) {
    // Display the selected address in the address-details span
    const addressDetailsElement = document.getElementById('address-details');
    addressDetailsElement.textContent = place.formatted_address;

    // Show the confirm button
    const confirmButton = document.getElementById('confirm-address');
    confirmButton.classList.remove('hidden');

    // Attach event to confirm the selected address
    confirmButton.addEventListener('click', () => {
      console.log("Address confirmed:", place);
      // You could send this data to the server or populate hidden form fields with the selected place data
    });
  }
}
