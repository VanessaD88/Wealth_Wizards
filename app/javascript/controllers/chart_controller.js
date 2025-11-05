import { Controller } from "@hotwired/stimulus"
console.log(" Charts controller connected");

console.log("Creating chart for:", document.getElementById("level1"))

export default class extends Controller {
  static targets = ["canvas"];

  worldPopulation = {
    datasets: [{
      data: [504, 496]
    }],
    // These labels appear in the legend and in the tooltips when hovering different arcs
    labels: [
      'Men',
      'Women'
    ]
  };

  connect() {
    // TODO: console.log something!
    console.log("Doughnut Chart Controller connected");

    const labels = ['Men', 'Women'];
    const data = [504, 496];

    this.chart = new Chart(this.canvasTarget, {
      type: "doughnut",
      data: {
        labels,
        datasets: [{
          label: "World Population (millions)",
          data,
          backgroundColor: [
            'rgb(54, 162, 235)',
            'rgb(255, 99, 132)'
          ],
          hoverOffset: 4
        }]
      }
    });
  }
}
