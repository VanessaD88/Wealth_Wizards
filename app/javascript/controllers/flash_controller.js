import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { timeout: { type: Number, default: 4000 } }

  connect() {
    this.timeoutId = window.setTimeout(() => this.close(), this.timeoutValue)
  }

  disconnect() {
    if (this.timeoutId) window.clearTimeout(this.timeoutId)
  }

  close() {
    const closeBtn = this.element.querySelector('[data-bs-dismiss="alert"]')
    if (closeBtn) { closeBtn.click() } else { this.element.remove() }
  }
}
