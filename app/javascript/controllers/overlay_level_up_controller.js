import { Controller } from "@hotwired/stimulus"

// overlay shown when a user levels up (according to level-up defined in challenges controller)
export default class extends Controller {
  static values = { show: Boolean }

  connect() {
    console.log("Level-up overlay connected. Show value:", this.showValue)
    if (this.showValue) this.showOverlay()
  }

  showOverlay() {
    const overlay = document.getElementById("level-up-overlay")
    overlay.classList.remove("d-none")
  }

  hideOverlay() {
    const overlay = document.getElementById("level-up-overlay")
    overlay.classList.add("d-none")
  }
}
