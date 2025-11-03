# Gold Rain Animation System - Usage Guide

## Overview

The gold rain animation system supports two distinct modes:

1. **Full-Screen Mode**: Dramatic effect for level ups (covers entire viewport)
2. **Localized Mode**: Subtle effect for challenge cards (contained within specific element)

## Architecture

### Files
- **Controller**: `app/javascript/controllers/gold_rain_controller.js`
- **Styles**: `app/assets/stylesheets/components/_gold-rain.scss`
- **Partial**: `app/views/shared/_gold_rain.html.erb` (optional, for Rails integration)

## Usage Examples

### 1. Full-Screen Mode (Level Up)

**HTML/ERB:**
```erb
<%# In level completion popup or level up page %>
<div data-controller="gold-rain" 
     data-gold-rain-mode-value="fullscreen"
     data-gold-rain-duration-value="5000"
     data-gold-rain-intensity-value="2"
     data-gold-rain-auto-trigger-value="true">
</div>
```

**JavaScript (Manual Trigger):**
```javascript
// Find the controller element
const goldRainElement = document.querySelector('[data-controller="gold-rain"]')
const controller = this.application.getControllerForElementAndIdentifier(
  goldRainElement, 
  "gold-rain"
)
controller.trigger()
```

**Features:**
- Covers entire viewport (100vh × 100vw)
- Fixed position (stays in place during scroll)
- Higher z-index (9999) to appear above all content
- Larger coins (24px base size)
- More coins (60 base, multiplied by intensity)
- Longer duration (5 seconds default)
- Dramatic rotation (900° full rotation)

---

### 2. Localized Mode (Challenge Card)

**HTML/ERB:**
```erb
<%# In challenge card (ensure parent has position: relative) %>
<div class="challenge-card" style="position: relative; overflow: hidden;">
  <%# Gold rain container inside card %>
  <div data-controller="gold-rain" 
       data-gold-rain-mode-value="localized"
       data-gold-rain-duration-value="3000"
       data-gold-rain-intensity-value="1"
       data-gold-rain-auto-trigger-value="false">
  </div>
  
  <%# Challenge card content %>
  <div class="card-body">
    <!-- Your challenge content -->
  </div>
</div>
```

**JavaScript (Trigger on Correct Answer):**
```javascript
// In your challenge submission handler
if (answerIsCorrect) {
  const cardElement = document.querySelector('.challenge-card')
  const goldRainContainer = cardElement.querySelector('[data-controller="gold-rain"]')
  
  if (goldRainContainer) {
    const controller = this.application.getControllerForElementAndIdentifier(
      goldRainContainer,
      "gold-rain"
    )
    controller.trigger()
  }
}
```

**Features:**
- Contained within parent element
- Absolute position (relative to parent)
- Lower z-index (10) to stay within card
- Smaller coins (18px base size)
- Fewer coins (20 base, multiplied by intensity)
- Shorter duration (3 seconds default)
- Subtle rotation (450° rotation)

---

## Controller Values (Data Attributes)

| Attribute | Type | Default | Description |
|-----------|------|---------|-------------|
| `data-gold-rain-mode-value` | String | `"fullscreen"` | `"fullscreen"` or `"localized"` |
| `data-gold-rain-intensity-value` | Number | `1` | Multiplier for coin count (1-3 recommended) |
| `data-gold-rain-duration-value` | Number | `5000` | Animation duration in milliseconds |
| `data-gold-rain-auto-trigger-value` | Boolean | `false` | Automatically trigger on connect |

### Intensity Guide

- **1** (Low): Subtle celebration
  - Full-screen: 60 coins
  - Localized: 20 coins

- **2** (Medium): Standard celebration
  - Full-screen: 120 coins
  - Localized: 40 coins

- **3** (High): Epic celebration
  - Full-screen: 180 coins
  - Localized: 60 coins

---

## Integration Examples

### Example 1: Level Up (Full-Screen)

```erb
<%# In levels#index or completion popup %>
<% if @level_completed %>
  <%= render "shared/gold_rain", 
      mode: "fullscreen",
      duration: 5000,
      intensity: 2,
      auto_trigger: true %>
<% end %>
```

### Example 2: Correct Answer (Challenge Card)

```erb
<%# In gameboard.html.erb %>
<div class="challenge-card card" style="position: relative; overflow: hidden;">
  <% if @show_answer_feedback && @answer_is_correct %>
    <%= render "shared/gold_rain", 
        mode: "localized",
        duration: 3000,
        intensity: 1,
        auto_trigger: true %>
  <% end %>
  
  <div class="card-body">
    <!-- Challenge content -->
  </div>
</div>
```

### Example 3: Manual Trigger (Stimulus Controller)

```javascript
// app/javascript/controllers/challenge_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["goldRain"]
  
  submitAnswer(event) {
    // ... handle answer submission ...
    
    if (this.answerIsCorrect) {
      // Trigger gold rain in challenge card
      const goldRainController = this.application.getControllerForElementAndIdentifier(
        this.goldRainTarget,
        "gold-rain"
      )
      goldRainController.trigger()
    }
  }
}
```

```erb
<%# In your view %>
<div data-controller="challenge">
  <div class="challenge-card">
    <div data-challenge-target="goldRain"
         data-controller="gold-rain"
         data-gold-rain-mode-value="localized">
    </div>
    <!-- Content -->
  </div>
</div>
```

---

## Visual Differences

### Full-Screen Mode
- **Position**: Fixed (viewport)
- **Coverage**: Entire screen
- **Coin Size**: 24px ± 3px
- **Coin Count**: 60 × intensity
- **Columns**: 8
- **Duration**: 5 seconds
- **Rotation**: 900°
- **Glow**: Strong (12px blur)
- **Use Case**: Level completion, major milestones

### Localized Mode
- **Position**: Absolute (parent container)
- **Coverage**: Card/container bounds
- **Coin Size**: 18px ± 3px
- **Coin Count**: 20 × intensity
- **Columns**: 4
- **Duration**: 3 seconds
- **Rotation**: 450°
- **Glow**: Subtle (6px blur)
- **Use Case**: Correct answers, small achievements

---

## Performance Considerations

1. **Coin Count**: Use intensity sparingly. Intensity 3 may cause lag on older devices.
2. **Mobile**: Automatically reduces effects on mobile devices (< 768px width)
3. **Cleanup**: Coins are automatically removed after animation completes
4. **GPU Acceleration**: Uses `transform: translateZ(0)` for hardware acceleration
5. **Will-Change**: Optimized with `will-change: transform, opacity`

---

## Troubleshooting

### Animation doesn't trigger
- Check that `data-controller="gold-rain"` is present
- Verify mode is set correctly: `"fullscreen"` or `"localized"`
- For localized mode, ensure parent has `position: relative`
- Check browser console for JavaScript errors

### Coins don't appear in localized mode
- Ensure parent container has `position: relative`
- Check parent has `overflow: hidden` to contain coins
- Verify parent has explicit height/width

### Performance issues
- Reduce `intensity-value` (use 1 instead of 2 or 3)
- Reduce `duration-value` (use 3000 instead of 5000)
- Test on target devices/browsers

### Animation overlaps incorrectly
- For full-screen: ensure z-index is appropriate (9999)
- For localized: ensure parent z-index is lower than coin container (10)

---

## Future Enhancements

- [ ] Custom coin images/assets
- [ ] Sound effects on trigger
- [ ] Configurable coin paths (curved, spiraling)
- [ ] Particle effects
- [ ] Different coin types for different achievements

