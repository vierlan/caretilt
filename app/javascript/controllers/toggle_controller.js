
import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="toggle"
export default class extends Controller {
  static targets = ["button", "input", "label"];

  connect() {
    console.log("toggle connected")
    const currentValue = this.inputTarget.value;
    console.log("currentValue: ", currentValue);
    this.updateToggle();
  }

  toggle() {
    console.log("toggle clicked");
    const currentValue = this.inputTarget.value;
    console.log("currentValue: ", currentValue);
    this.updateToggle();
  }

  updateToggle() {
    console.log("toggle updated")
    const toggleType = this.data.get("type"); // Get the type of toggle from data attribute
    const isChecked = this.inputTarget.checked;

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
    console.log("get label type: ", type, " isChecked: ", isChecked);
    if (type === "vacant") {
      return isChecked ? '<span class="font-lg text-gray-900 font-bold">Vacant</span>' : '<span class="font-lg text-gray-200">Not Vacant</span>';
    } else if (type === "status") {
      return isChecked ? '<span class="font-lg text-gray-900 font-bold">Verified</span>' : '<span class="font-lg text-gray-200">Inactive</span>';
    } else {
      console.warn("Unknown type: ", type);
      return '<span class="font-lg text-gray-200">Unknown</span>';
    }
  }
}
