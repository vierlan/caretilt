import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="open"
export default class extends Controller {
  connect() {
    console.log("open connected")
  }

  static targets = ["info"];

  toggleHiddenField(event) {
    event.preventDefault();
    const hiddenField = event.currentTarget.nextElementSibling;
    if (hiddenField.classList.contains("hidden")) {
      hiddenField.classList.remove("hidden");
    } else {
      hiddenField.classList.add("hidden");
    }
  }
}
