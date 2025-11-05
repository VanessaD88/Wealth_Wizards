import { Controller } from "@hotwired/stimulus"

console.log("Creating chart for:", document.getElementById("level1"))

export default class extends Controller {
  static targets = ["level"]

  connect() {
    console.log("Chart controller connected");

    // Register the datalabels plugin
    Chart.register(ChartDataLabels)

    this.levelTargets.forEach((canvas) => {
      const level = parseInt(canvas.dataset.level)
      const balance = parseFloat(canvas.dataset.userBalance)
      const levelName = canvas.dataset.userLevel || ""

      let progress = 0

      // --- LEVEL 1 ---
      if (level === 1) {
        if (levelName.includes("1")) progress = Math.min((balance / 10000) * 100, 100)
        else if (["2","3","4"].some(n => levelName.includes(n))) progress = 100
      }

      // --- LEVEL 2 ---
      if (level === 2) {
        if (levelName.includes("1")) progress = 0
        else if (levelName.includes("2")) progress = Math.min(((balance - 10000) / 20000) * 100, 100)
        else if (["3","4"].some(n => levelName.includes(n))) progress = 100
      }

      // --- LEVEL 3 ---
      if (level === 3) {
        if (["1","2"].some(n => levelName.includes(n))) progress = 0
        else if (levelName.includes("3")) progress = Math.min(((balance - 30000) / 10000) * 100, 100)
        else if (levelName.includes("complete")) progress = 100
      }

      console.log(`Level ${level} progress:`, progress)

      // Create horizontal bar chart
      new Chart(canvas, {
        type: "bar",
        data: {
          labels: [""],
          datasets: [
            { data: [progress], backgroundColor: "#3B5D43", borderRadius: 10, barThickness: 25 },
            { data: [100 - progress], backgroundColor: "rgba(79,114,88,0.3)", borderRadius: 10, barThickness: 25 },
          ]
        },
        options: {
          indexAxis: "y",
          responsive: true,
          maintainAspectRatio: false,
          scales: { x: { display: false, stacked: true }, y: { display: false, stacked: true } },
          plugins: {
            legend: { display: false },
            tooltip: { enabled: true },
            datalabels: {
              anchor: "center",
              align: "center",
              color: "#F4F1E7",
              font: { weight: "bold", size: 14 },
              formatter: () => `${progress.toFixed(0)}%`,
            }
          }
        }
      })
    })
  }
}
