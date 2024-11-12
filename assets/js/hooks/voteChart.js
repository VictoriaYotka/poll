import Chart from "chart.js/auto";

let VoteChart = {
  mounted() {
    this.voteChart = document.getElementById("voteChart");
    const ctx = this.el.getContext("2d");
    const labels = JSON.parse(this.el.getAttribute("phx-value-labels"));
    const votes = JSON.parse(this.el.getAttribute("phx-value-votes"));
    const voters = JSON.parse(this.el.getAttribute("phx-value-voters"));

    const plugin = {
      id: "customCanvasBackgroundColor",
      beforeDraw: (chart, args, options) => {
        const { ctx } = chart;
        ctx.save();
        ctx.globalCompositeOperation = "destination-over";
        ctx.fillStyle = options.color || "#f5f5f5";
        ctx.fillRect(0, 0, chart.width, chart.height);
        ctx.restore();
      },
    };

    this.chart = new Chart(ctx, {
      type: "bar",
      data: {
        labels: labels,
        datasets: [
          {
            label: "",
            data: votes,
            backgroundColor: "rgba(75, 29, 196, 0.8)", // Indigo-500 color for bars
            hoverBackgroundColor: "rgba(55, 48, 163, 0.8)", // Indigo-800 for hover
            barThickness: 10, // Extremely thin bars
            maxBarThickness: 10, // Ensures maximum bar thickness
          },
        ],
      },
      options: {
        responsive: true,
        maintainAspectRatio: true,
        indexAxis: "y",
        plugins: {
          customCanvasBackgroundColor: {
            color: "	whiteSmoke",
          },
          tooltip: {
            enabled: true,
            yAlign: "top",
            padding: "14",
            backgroundColor: "rgb(75, 29, 196, 0.8)",
            titleColor: "#ffffff",
            displayColors: false,
            titleFont: { size: 14 },
            bodyFont: { size: 14 },
            callbacks: {
              label: function (tooltipItem) {
                return `Voted: ${voters[tooltipItem.dataIndex]}`;
              },
            },
          },
        },
        scales: {
          x: {
            beginAtZero: true,
            grid: {
              display: false,
            },
            ticks: {
              font: {
                size: 1,
                weight: "bold",
              },
            },
          },
          y: {
            beginAtZero: true,
            grid: {
              display: false,
            },
            ticks: {
              font: {
                size: 16,
                weight: "bold",
              },
            },
          },
        },
        layout: {
          padding: 10,
        },
        legend: {
          display: false, // Hide legend
        },
        animation: {
          duration: 500,
          easing: "easeOutQuart",
        },
        aspectRatio: 1.5,
      },
      plugins: [plugin],
    });
  },
  updated() {},
};

export default VoteChart;