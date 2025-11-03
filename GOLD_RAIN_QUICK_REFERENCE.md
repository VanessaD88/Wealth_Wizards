# Gold Rain - Quick Reference

## Two Modes

### 1. Full-Screen (Level Up)
```erb
<div data-controller="gold-rain" 
     data-gold-rain-mode-value="fullscreen"
     data-gold-rain-duration-value="5000"
     data-gold-rain-intensity-value="2"
     data-gold-rain-auto-trigger-value="true">
</div>
```
- Covers entire viewport
- 60+ coins (intensity × 60)
- 5 seconds duration
- For: Level completion, major milestones

### 2. Localized (Challenge Card)
```erb
<div class="challenge-card" style="position: relative; overflow: hidden;">
  <div data-controller="gold-rain" 
       data-gold-rain-mode-value="localized"
       data-gold-rain-duration-value="3000"
       data-gold-rain-intensity-value="1">
  </div>
  <!-- Card content -->
</div>
```
- Contained within parent element
- 20+ coins (intensity × 20)
- 3 seconds duration
- For: Correct answers in challenge cards

## Manual Trigger (JavaScript)
```javascript
const controller = this.application.getControllerForElementAndIdentifier(
  element,
  "gold-rain"
)
controller.trigger()
```

## Intensity Levels
- **1**: Subtle (default for localized)
- **2**: Standard (default for fullscreen)
- **3**: Epic (use sparingly)

## Important Notes
- Localized mode requires parent with `position: relative`
- Localized mode requires parent with `overflow: hidden`
- Auto-trigger can be enabled with `data-gold-rain-auto-trigger-value="true"`
- Coins auto-cleanup after animation completes

