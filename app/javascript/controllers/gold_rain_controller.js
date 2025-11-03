import { Controller } from "@hotwired/stimulus"

// Gold Rain Animation Controller
// Handles both full-screen (level up) and localized (challenge card) gold rain effects
// 
// Usage:
// Full-screen: <div data-controller="gold-rain" data-gold-rain-mode-value="fullscreen"></div>
// Localized: <div data-controller="gold-rain" data-gold-rain-mode-value="localized"></div>
// Trigger animation: this.goldRainController.trigger()

export default class extends Controller {
  static values = {
    mode: { type: String, default: "fullscreen" }, // "fullscreen" or "localized"
    intensity: { type: Number, default: 1 }, // 1-3 (affects coin count)
    duration: { type: Number, default: 5000 }, // Animation duration in ms
    autoTrigger: { type: Boolean, default: false } // Auto-trigger on connect
  }

  connect() {
    // Initialize the gold rain container based on mode
    this.initializeContainer()
    
    // Auto-trigger if enabled (useful for page load scenarios)
    if (this.autoTriggerValue) {
      this.trigger()
    }
  }

  disconnect() {
    // Clean up animation on disconnect
    this.element.querySelectorAll('.gold-rain-coin').forEach(coin => coin.remove())
  }

  // Public method to trigger the animation
  trigger() {
    this.createRain()
  }

  // Initialize container based on mode
  initializeContainer() {
    if (this.modeValue === "fullscreen") {
      // Full-screen mode: fixed position covering entire viewport
      this.element.classList.add("gold-rain-fullscreen")
      this.element.style.cssText = `
        position: fixed;
        top: 0;
        left: 0;
        width: 100%;
        height: 100vh;
        pointer-events: none;
        z-index: 9999;
        overflow: hidden;
      `
    } else {
      // Localized mode: relative to parent container (e.g., challenge card)
      this.element.classList.add("gold-rain-localized")
      this.element.style.cssText = `
        position: absolute;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        pointer-events: none;
        z-index: 10;
        overflow: hidden;
        border-radius: inherit;
      `
    }
  }

  // Create and animate gold coins
  createRain() {
    const coinCount = this.getCoinCount()
    const containerHeight = this.modeValue === "fullscreen" 
      ? window.innerHeight 
      : this.element.offsetHeight

    // Clear any existing coins
    this.element.innerHTML = ""

    // Create rain columns
    const columns = this.modeValue === "fullscreen" ? 8 : 4 // Fewer columns for localized
    
    for (let col = 0; col < columns; col++) {
      const column = document.createElement("div")
      column.className = "gold-rain-column"
      column.style.cssText = `
        position: absolute;
        left: ${(col / columns) * 100}%;
        width: ${100 / columns}%;
        height: 100%;
        top: 0;
      `

      // Create coins for this column
      const coinsPerColumn = Math.floor(coinCount / columns)
      for (let i = 0; i < coinsPerColumn; i++) {
        const coin = this.createCoin(i, coinsPerColumn, containerHeight)
        column.appendChild(coin)
      }

      this.element.appendChild(column)
    }
  }

  // Create a single gold coin element
  createCoin(index, totalCoins, containerHeight) {
    const coin = document.createElement("img")
    coin.className = "gold-rain-coin"
    coin.src = "//cdn04.pinkoi.com/pinkoi.site/my_membership/ic_pcoins.svg"
    coin.alt = "Gold coin"
    
    // Size varies based on mode and intensity
    const baseSize = this.modeValue === "fullscreen" ? 24 : 18
    const size = baseSize + (Math.random() * 6 - 3) // Random variation
    coin.style.cssText = `
      position: absolute;
      width: ${size}px;
      height: ${size}px;
      left: ${Math.random() * 90 + 5}%;
      top: -${size}px;
      filter: drop-shadow(0 0 8px rgba(201, 162, 78, 0.6)) drop-shadow(0 0 4px rgba(201, 162, 78, 0.4));
      will-change: transform, opacity;
    `

    // Calculate animation delay for staggered effect
    const delay = (index / totalCoins) * (this.durationValue / 1000) * 0.5

    // Apply animation
    coin.style.animation = `
      gold-rain-${this.modeValue} 
      ${this.durationValue / 1000}s 
      ${delay}s 
      cubic-bezier(0.4, 0.0, 0.2, 1) 
      forwards
    `

    // Remove coin after animation completes
    setTimeout(() => {
      if (coin.parentNode) {
        coin.remove()
      }
    }, this.durationValue + (delay * 1000) + 500)

    return coin
  }

  // Get coin count based on mode and intensity
  getCoinCount() {
    const baseCount = this.modeValue === "fullscreen" ? 60 : 20
    return Math.floor(baseCount * this.intensityValue)
  }
}

