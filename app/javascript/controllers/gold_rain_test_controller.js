import { Controller } from "@hotwired/stimulus"

// Test Controller for Gold Rain Effects - Used only on /test/gold-rain page
// Handles triggering both fullscreen and localized effects for testing
export default class extends Controller {
  // Helper method to get and trigger gold rain controller
  triggerGoldRain(containerId, logMessage) {
    const container = document.getElementById(containerId)
    if (!container) {
      console.error(`${containerId} not found`)
      return
    }

    const controller = this.application.getControllerForElementAndIdentifier(container, "gold-rain")
    if (controller) {
      controller.trigger()
      console.log(logMessage)
    } else {
      console.error("Gold rain controller not found")
    }
  }

  // Trigger fullscreen effect (intensity 2 - standard)
  triggerFullscreen(event) {
    event.preventDefault()
    this.triggerGoldRain("fullscreen-rain-container", "✨ Fullscreen gold rain triggered!")
  }

  // Trigger fullscreen effect with intensity 3 (epic)
  triggerFullscreenIntense(event) {
    event.preventDefault()
    
    // Create a temporary fullscreen container with intensity 3
    const tempContainer = document.createElement("div")
    tempContainer.setAttribute("data-controller", "gold-rain")
    tempContainer.setAttribute("data-gold-rain-mode-value", "fullscreen")
    tempContainer.setAttribute("data-gold-rain-duration-value", "6000")
    tempContainer.setAttribute("data-gold-rain-intensity-value", "3")
    tempContainer.setAttribute("data-gold-rain-auto-trigger-value", "false")
    tempContainer.style.cssText = `
      position: fixed;
      top: 0;
      left: 0;
      width: 100%;
      height: 100vh;
      pointer-events: none;
      z-index: 9999;
      overflow: hidden;
    `
    
    document.body.appendChild(tempContainer)

    // Wait for controller to connect, then trigger
    setTimeout(() => {
      const controller = this.application.getControllerForElementAndIdentifier(
        tempContainer,
        "gold-rain"
      )
      if (controller) {
        controller.trigger()
        console.log("🎆 Intense fullscreen gold rain triggered!")
      }

      // Clean up after animation completes
      setTimeout(() => {
        tempContainer.remove()
      }, 7000)
    }, 100)
  }

  // Trigger localized effect (intensity 1 - subtle)
  triggerLocalized(event) {
    event.preventDefault()
    this.triggerGoldRain("localized-rain-container", "✨ Localized gold rain triggered!")
  }

  // Trigger localized effect with intensity 2
  triggerLocalizedIntense(event) {
    event.preventDefault()
    this.triggerGoldRain("localized-rain-intense-container", "🎯 Intense localized gold rain triggered!")
  }
}

