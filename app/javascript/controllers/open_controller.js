import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="open"
export default class extends Controller {
  connect() {
    console.log("open connected")
  }

  static targets = ["info", "company"];

  toggleHiddenField(event) {
    event.preventDefault();
    const hiddenField = event.currentTarget.nextElementSibling;
    if (hiddenField.classList.contains("hidden")) {
      hiddenField.classList.remove("hidden");
    } else {
      hiddenField.classList.add("hidden");
    }
  }

  toggleCompany(event) {
    event.preventDefault();
    if (this.companyTarget.classList.contains("hidden")) {
      this.companyTarget.classList.remove("hidden");
    } else {
      this.companyTarget.classList.add("hidden");
  }
}
}
