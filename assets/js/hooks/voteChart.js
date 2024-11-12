import Chart from "chart.js/auto";

let VoteChart = {
  mounted() {
    const ctx = this.el.querySelector("#voteChart").getContext("2d");
    const labels = JSON.parse(this.el.getAttribute("data-labels"));
    const votes = JSON.parse(this.el.getAttribute("data-votes"));
    const voters = JSON.parse(this.el.getAttribute("data-voters"));

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
            backgroundColor: "rgba(75, 29, 196, 0.8)",
            hoverBackgroundColor: "rgba(55, 48, 163, 0.8)",
            barThickness: 10,
            maxBarThickness: 10,
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
          display: false,
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

  updated() {
    const newVotes = JSON.parse(this.el.getAttribute("data-votes"));
    const newVoters = JSON.parse(this.el.getAttribute("data-voters"));

    this.chart.data.datasets[0].data = newVotes;
    this.chart.options.plugins.tooltip.callbacks.label = (tooltipItem) =>
      `Voted: ${newVoters[tooltipItem.dataIndex]}`;

    this.chart.update();
  },
};

export default VoteChart;
