import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="toggle"
export default class extends Controller {
  static targets = ["button", "input", "label"];

  connect() {
    console.log("toggle connected");
    this.updateToggle();  // Initialize the toggle state on connect
  }

  toggle() {
    console.log("toggle clicked");

    // Toggle the input's checked state
    this.inputTarget.checked = !this.inputTarget.checked;

    this.updateToggle();  // Update the toggle UI
  }

  updateToggle() {
    const toggleType = this.data.get("type");  // Get the type of toggle from data attribute
    const isChecked = this.inputTarget.checked;  // Use the checked state of the hidden input

    // Update the button style based on the checked state
    if (isChecked) {
      this.buttonTarget.classList.add("bg-primary");
      this.buttonTarget.classList.remove("bg-gray-200");
      this.buttonTarget.setAttribute("aria-checked", "true");
      this.buttonTarget.querySelector("span").classList.add("translate-x-5");
      this.buttonTarget.querySelector("span").classList.remove("translate-x-0");
      this.labelTarget.innerHTML = this.getLabel(toggleType, true);
    } else {
      this.buttonTarget.classList.add("bg-gray-200");
      this.buttonTarget.classList.remove("bg-primary");
      this.buttonTarget.setAttribute("aria-checked", "false");
      this.buttonTarget.querySelector("span").classList.add("translate-x-0");
      this.buttonTarget.querySelector("span").classList.remove("translate-x-5");
      this.labelTarget.innerHTML = this.getLabel(toggleType, false);
    }
  }

  getLabel(type, isChecked) {
    if (type === "vacant") {
      return isChecked ? '<span class="font-lg text-gray-900 font-bold">Vacant</span>' : '<span class="font-lg text-gray-200">Not Vacant</span>';
    } else if (type === "status") {
      return isChecked ? '<span class="font-lg text-gray-900 font-bold">Verified</span>' : '<span class="font-lg text-gray-200">Inactive</span>';
    } else {
      return '<span class="font-lg text-gray-200">Unknown</span>';
    }
  }
}
