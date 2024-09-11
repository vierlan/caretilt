import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="faq"
export default class extends Controller {
  connect() {
    console.log("controller connected")
  }

  static targets = ["answer", "iconOpen", "iconClosed"];

  toggle(event) {
    // Toggle visibility of the answer
    const isExpanded = event.currentTarget.getAttribute("aria-expanded") === "true";
    event.currentTarget.setAttribute("aria-expanded", !isExpanded);

    // Toggle visibility of the answer content
    this.answerTargets.forEach(answer => {
      if (answer.id === event.currentTarget.getAttribute("aria-controls")) {
        answer.classList.toggle("hidden")
      }
    });

    // Toggle icons
    this.iconOpenTargets.forEach(iconOpen => {
      if (iconOpen.closest("button") === event.currentTarget) {
        iconOpen.classList.toggle("hidden")
      }
    });
    this.iconClosedTargets.forEach(iconClosed => {
      if (iconClosed.closest("button") === event.currentTarget) {
        iconClosed.classList.toggle("hidden")
      }
    });
  }
}
