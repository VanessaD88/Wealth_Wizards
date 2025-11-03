# Gold Rain Animation System

## Quick Start

Two modes for different use cases:
- **Fullscreen**: Level ups (covers entire screen)
- **Localized**: Challenge cards (contained within card)

## Usage

### Full-Screen Mode (Level Up)

```erb
<div data-controller="gold-rain" 
     data-gold-rain-mode-value="fullscreen"
     data-gold-rain-duration-value="5000"
     data-gold-rain-intensity-value="2"
     data-gold-rain-auto-trigger-value="true">
</div>
```

**When to use:** Level completion, major milestones  
**Characteristics:** 120 coins, 5 seconds, dramatic 900° rotation

### Localized Mode (Challenge Card)

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

**When to use:** Correct answers, small achievements  
**Characteristics:** 20 coins, 3 seconds, subtle 450° rotation

**Important:** Parent must have `position: relative` and `overflow: hidden`

### Using the Partial Helper

```erb
<%= render "shared/gold_rain", 
    mode: "fullscreen",
    duration: 5000,
    intensity: 2,
    auto_trigger: true %>
```

### Manual Trigger (JavaScript)

```javascript
const element = document.querySelector('[data-controller="gold-rain"]')
const controller = this.application.getControllerForElementAndIdentifier(
  element,
  "gold-rain"
)
controller.trigger()
```

## Configuration

### Data Attributes

| Attribute | Type | Default | Description |
|-----------|------|---------|-------------|
| `data-gold-rain-mode-value` | String | `"fullscreen"` | `"fullscreen"` or `"localized"` |
| `data-gold-rain-intensity-value` | Number | `1` | 1-3 (multiplies coin count) |
| `data-gold-rain-duration-value` | Number | `5000` | Animation duration in ms |
| `data-gold-rain-auto-trigger-value` | Boolean | `false` | Auto-trigger on connect |

### Intensity Guide

- **1**: Subtle (60 coins fullscreen, 20 localized)
- **2**: Standard (120 coins fullscreen, 40 localized) - **Recommended default**
- **3**: Epic (180 coins fullscreen, 60 localized) - Use sparingly

## Technical Details

### File Structure

- **Controller**: `app/javascript/controllers/gold_rain_controller.js`
- **Styles**: `app/assets/stylesheets/components/_gold-rain.scss`
- **Partial**: `app/views/shared/_gold_rain.html.erb` (optional helper)
- **Test Page**: `/test/gold-rain` (for testing both effects)

### Comparison

| Feature | Fullscreen | Localized |
|---------|-----------|-----------|
| Position | Fixed (viewport) | Absolute (parent) |
| Coverage | 100vh × 100vw | Parent bounds |
| Z-index | 9999 | 10 |
| Coin Size | 24px ± 3px | 18px ± 3px |
| Base Coins | 60 | 20 |
| Columns | 8 | 4 |
| Duration | 5 seconds | 3 seconds |
| Rotation | 900° | 450° |
| Glow | Strong | Subtle |

## Integration Examples

### Level Completion Popup

```erb
<% if @level_completed %>
  <%= render "shared/gold_rain", 
      mode: "fullscreen",
      duration: 5000,
      intensity: 2,
      auto_trigger: true %>
  
  <div class="modal">
    <!-- Completion message -->
  </div>
<% end %>
```

### Correct Answer in Challenge Card

```erb
<div class="challenge-card" style="position: relative; overflow: hidden;">
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

### Manual Trigger from Stimulus

```javascript
// In your challenge controller
submitAnswer(event) {
  if (this.answerIsCorrect) {
    const goldRainElement = this.element.querySelector('[data-controller="gold-rain"]')
    const controller = this.application.getControllerForElementAndIdentifier(
      goldRainElement,
      "gold-rain"
    )
    controller.trigger()
  }
}
```

## Testing

Visit `/test/gold-rain` to see both effects in action with interactive buttons.

## Troubleshooting

**Animation doesn't trigger:**
- Check `data-controller="gold-rain"` is present
- Verify mode is `"fullscreen"` or `"localized"`
- For localized: ensure parent has `position: relative` and `overflow: hidden`

**Coins don't appear in localized mode:**
- Parent must have `position: relative`
- Parent must have `overflow: hidden`
- Parent must have explicit height/width

**Performance issues:**
- Reduce `intensity-value` to 1
- Reduce `duration-value` to 3000
- Test on target devices
