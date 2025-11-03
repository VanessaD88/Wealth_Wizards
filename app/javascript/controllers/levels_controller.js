// Controller to view level badges on dashboard

import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="levels"
export default class extends Controller {
  static targets = ["icon"]
  static values = { currentLevel: String }

  connect() {
    this.updateIcons()
  }

  updateIcons() {
    const levelStr = this.currentLevelValue // e.g., "Level 3: Building a Nest Egg"
    console.log("currentLevelValue:", this.currentLevelValue)
    let levelNumber = 0
    let isCompleted = false // game completed

    // Check for "completed" first
    if (levelStr.includes("completed")) {
      isCompleted = true
    } else {
      // Extract the numeric level from the string if not completed
      const match = levelStr.match(/Level (\d+)/)
      levelNumber = match ? parseInt(match[1], 10) : 0
    }

    this.iconTargets.forEach(icon => {
      const iconLevel = parseInt(icon.dataset.levelsLevelValue, 10)
      let showIcon = false

      if (isCompleted) {
        showIcon = true                  // show all icons
      } else if (levelNumber === 1) {
        showIcon = false                 // all icons covered
      } else if (levelNumber === 2) {
        showIcon = (iconLevel === 1)    // show only icon 1
      } else if (levelNumber === 3) {
        showIcon = (iconLevel === 1 || iconLevel === 2) // show icons 1 + 2
      }

      // Apply overlay logic
      if (showIcon) {
        icon.classList.add("active")      // remove overlay
      } else {
        icon.classList.remove("active")   // keep overlay
      }
    })
  }
}
