import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="password-visibility"
export default class extends Controller {
  static targets = ["password", "toggle"];

  connect() {
    console.log("Connected to password visibility controller");
  }

  toggleVisibility() {
    const passwordField = this.passwordTarget;
    const toggleIcon = this.toggleTarget;

    // Toggle the password field type between 'text' and 'password'
    if (passwordField.type === "password") {
      passwordField.type = "text";
      toggleIcon.classList.remove("fa-regular fa-eye-slash");
      toggleIcon.classList.add("fa-regular fa-eye");
    } else {
      passwordField.type = "password";
      toggleIcon.classList.remove("fa-regular fa-eye");
      toggleIcon.classList.add("fa-regular fa-eye-slash");
    }
  }
}
