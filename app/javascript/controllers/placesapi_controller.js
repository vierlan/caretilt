import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["place", "resultsContainer"]

  connect() {
    console.log("Stimulus Places controller connected");
    this.initPlacesAutocomplete();
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
        this.displayPhotos(place.photos);  // Include photo display logic
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

    // Attach the event listener for the confirmation button
    confirmButton.addEventListener('click', () => {
      this.populateFormWithAddress(place);
    });
  }

  populateFormWithAddress(place) {
    // Extract relevant address components
    const addressComponents = place.address_components;

    let name = '';
    let street = '';
    let street2 = '';
    let city = '';
    let postcode = '';
    let phoneNumber = '';
    let website = '';

    // Loop through the address components to find the desired information
    addressComponents.forEach((component) => {
      const types = component.types;
      if (types.includes('street_number') || types.includes('route')) {
        street += component.long_name + ' ';
      } else if (types.includes('locality')) {
        city = component.long_name;
      } else if (types.includes('postal_code')) {
        postcode = component.long_name;
      } else if (types.includes('postal_town')) {
        street2 = component.long_name;
      } else if (types.includes('administrative_area_level_2')) {
        city = component.short_name;
      }
    });

    if (place.name) {
      name = place.name;
    }
    if (place.formatted_phone_number) {
      phoneNumber = place.formatted_phone_number;
    }
    if (place.website) {
      website = place.website;
    }

    // Populate the form fields with the extracted values
    document.getElementById('address1').value = street.trim();
    document.getElementById('address2').value = street2.trim();
    document.getElementById('city').value = city;
    document.getElementById('postcode').value = postcode.replaceAll(/\s/g,'')
    document.getElementById('name').value = name;
    document.getElementById('phone_number').value = phoneNumber.replaceAll(/\s/g,'');
    document.getElementById('website').value = website;

    // Optionally, hide the confirm button after the address is populated
    const confirmButton = document.getElementById('confirm-address');
    confirmButton.classList.add('hidden');
  }

  displayPhotos(photos) {
    const photosContainer = document.getElementById('photos-container');
    photosContainer.innerHTML = ""; // Clear any previous photos

    if (photos && photos.length > 0) {
      photos.forEach((photo, index) => {
        const photoUrl = photo.getUrl({ maxWidth: 400, maxHeight: 400 });

        // Create the HTML for displaying the photo in the list
        const listItem = `
          <li class="relative">
            <div class="group aspect-h-7 aspect-w-10 block w-full overflow-hidden rounded-lg bg-gray-100 focus-within:ring-2 focus-within:ring-indigo-500 focus-within:ring-offset-2 focus-within:ring-offset-gray-100">
              <img src="${photoUrl}" alt="Place photo" class="pointer-events-none object-cover group-hover:opacity-75">
              <button type="button" class="absolute inset-0 focus:outline-none">
                <span class="sr-only">View details for ${index}</span>
              </button>
            </div>
          </li>
        `;

        // Append the photo to the results container
        photosContainer.innerHTML += listItem;
      });
    } else {
      photosContainer.innerHTML = "<p>No photos available for this location.</p>";
    }
  }
}
