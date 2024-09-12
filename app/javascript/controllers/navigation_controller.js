import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="navigation"
export default class extends Controller {
  static targets = ['button'];
  static values = { class: String } // Accept a custom class for active state

  connect() {
    // Highlight the current link when the page loads
    this.highlightCurrentButton();
  }

  highlightButton(event) {
    // Remove the active class from all buttons
    this.buttonTargets.forEach((button) => {
      button.classList.remove(this.classValue || 'bg-white'); // Use custom class if provided, otherwise default to 'bg-white'
    });

    // Add the active class to the clicked button
    event.currentTarget.classList.add(this.classValue || 'bg-white');
  }

  highlightCurrentButton() {
    const currentPath = window.location.pathname;

    this.buttonTargets.forEach((button) => {
      const linkElement = button.querySelector('a'); // Find the <a> inside the button div
      if (linkElement) {
        const linkPath = new URL(linkElement.href).pathname;
        if (linkPath === currentPath) {
          button.classList.add(this.classValue || 'bg-white'); // Highlight the current button
        } else {
          button.classList.remove(this.classValue || 'bg-white');
        }
      }
    });
  }
}
