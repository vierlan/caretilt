import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"

export default class extends Controller {
  connect() {
    console.log("Sortable controller connected")
    this.sortable = Sortable.create(this.element, {
      animation: 150,
      onEnd: this.updatePositions.bind(this)
    })
  }

  updatePositions(event) {
    // Recalculate the position of each media file after sorting
    const mediaItems = this.element.querySelectorAll('.form-image-card')
    mediaItems.forEach((item, index) => {
      const positionInput = item.querySelector('.media-position')
      positionInput.value = index + 1 // Update the position field with the new index
    })
  }
}
