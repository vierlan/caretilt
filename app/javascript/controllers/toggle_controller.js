import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="toggle"
export default class extends Controller {
  static targets = ["button", "input", "label"];


  connect() {
    console.log("toggle connected")
    this.updateToggle();
  }

  toggle() {
    console.log("toggle clicked")
    this.inputTarget.checked = !this.inputTarget.checked;
    this.updateToggle();
  }

  updateToggle() {
    console.log("toggle updated")
    if (this.inputTarget.checked) {
      this.buttonTarget.classList.add("bg-primary");
      this.buttonTarget.classList.remove("bg-gray-200");
      this.buttonTarget.setAttribute("aria-checked", "true");
      this.buttonTarget.querySelector("span").classList.add("translate-x-5");
      this.buttonTarget.querySelector("span").classList.remove("translate-x-0");
      this.labelTarget.innerHTML = '<span class="font-lg text-gray-900 font-bold">Vacant</span>';
    } else {
      this.buttonTarget.classList.add("bg-gray-200");
      this.buttonTarget.classList.remove("bg-primary");
      this.buttonTarget.setAttribute("aria-checked", "false");
      this.buttonTarget.querySelector("span").classList.add("translate-x-0");
      this.buttonTarget.querySelector("span").classList.remove("translate-x-5");
      this.labelTarget.innerHTML = '<span class="font-lg text-gray-200">Not Vacant</span>';
    }
  }
}
