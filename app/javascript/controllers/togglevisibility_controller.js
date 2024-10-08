// app/javascript/controllers/togglevisibility_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content", "iconOpen", "logo"]

  toggle() {
    // Toggle visibility for the mobile menu
    this.contentTarget.classList.toggle("hidden")

    // Hide the logo when menu is open
    this.logoTarget.classList.toggle("hidden")

    // Toggle visibility for the hamburger icon
    this.iconOpenTarget.classList.toggle("hidden")
  }
}
