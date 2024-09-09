// Import and register all your controllers from the importmap under controllers/*

import { application } from "controllers/application"

// Eager load all controllers defined in the import map under controllers/**/*_controller
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
eagerLoadControllersFrom("controllers", application)

// Lazy load controllers as they appear in the DOM (remember not to preload controllers in import map!)
// import { lazyLoadControllersFrom } from "@hotwired/stimulus-loading"
// lazyLoadControllersFrom("controllers", application)

document.addEventListener("DOMContentLoaded", function () {
    // Select all the question buttons
    const faqButtons = document.querySelectorAll("button[aria-controls]");

    faqButtons.forEach((button) => {
      button.addEventListener("click", function () {
        // Toggle the aria-expanded attribute
        const expanded = button.getAttribute("aria-expanded") === "true" || false;
        button.setAttribute("aria-expanded", !expanded);

        // Find the corresponding answer by id
        const answer = document.getElementById(button.getAttribute("aria-controls"));
        if (answer) {
          // Toggle visibility of the answer
          answer.style.display = expanded ? "none" : "block";

          // Toggle the icons
          const icons = button.querySelectorAll("svg");
          icons[0].classList.toggle("hidden", !expanded); // Show the collapsed icon
          icons[1].classList.toggle("hidden", expanded);  // Show the expanded icon
        }
      });
    });
  });