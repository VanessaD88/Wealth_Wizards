// app/javascript/controllers/overlay_instructions_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { show: Boolean }

  connect() {
    if (this.showValue) this.showOverlay()
  }

  showOverlay() {
    const overlay = document.getElementById("game-overlay")
    overlay.classList.remove("d-none")
  }

  hideOverlay() {
    const overlay = document.getElementById("game-overlay")
    overlay.classList.add("d-none")
  }
}
