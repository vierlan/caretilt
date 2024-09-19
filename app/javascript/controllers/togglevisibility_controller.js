import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="togglevisibility"
export default class extends Controller {
  connect() {
    console.log("toggle visibility controller connected")
  }

  static targets = ["content", "iconOpen", "iconClosed"];

  toggle(event) {
    const targetId = event.currentTarget.getAttribute("aria-controls");
    const content = document.getElementById(targetId);

    content.classList.toggle("hidden");

    const iconOpen = event.currentTarget.querySelector("[data-toggle-target='iconOpen']");
    const iconClosed = event.currentTarget.querySelector("[data-toggle-target='iconClosed']");

    if (iconOpen && iconClosed) {
      iconOpen.classList.toggle("hidden");
      iconClosed.classList.toggle("hidden");
    }
  }
  
}
