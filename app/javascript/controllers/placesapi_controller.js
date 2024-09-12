import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["place", "resultsContainer"]

  connect() {
    console.log("Stimulus Places controller connected")
    this.initPlacesAutocomplete()
  }

  initPlacesAutocomplete() {
    const input = this.placeTarget;
    const autocomplete = new google.maps.places.Autocomplete(input);

    // When the user selects an address, place it on the map
    autocomplete.addListener('place_changed', () => {
      const place = autocomplete.getPlace();
      if (place.geometry) {
        console.log("Place selected:", place);
        this.displayMapWithLocation(place.geometry.location);
        this.showSelectedAddress(place);
      } else {
        console.error("No geometry available for this place.");
      }
    });
  }

  displayMapWithLocation(location) {
    // Initialize map
    const map = new google.maps.Map(document.getElementById('map'), {
      center: location,
      zoom: 15,
    });

    // Place marker
    new google.maps.Marker({
      position: location,
      map: map,
    });
  }

  showSelectedAddress(place) {
    // Display selected address details
    const addressDetailsElement = document.getElementById('address-details');
    addressDetailsElement.textContent = place.formatted_address;

    // Show confirm button
    const confirmButton = document.getElementById('confirm-address');
    confirmButton.classList.remove('hidden');

    // Optionally, attach an event to confirm and submit the selected address
    confirmButton.addEventListener('click', () => {
      console.log("Address confirmed:", place);
      // Here, you could send this data to the server or populate form fields with the selected place data
      // For example, you might store the place_id or full address in hidden form fields
    });
  }
}
