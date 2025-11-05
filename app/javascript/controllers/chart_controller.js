import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="charts"
export default class extends Controller {
  connect() {
    // Register the plugin globally
    Chart.register(ChartDataLabels)

    // Gpt Code
    

    //Gpt Code End

  }
}
