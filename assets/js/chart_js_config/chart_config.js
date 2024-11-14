import chart_plugin from "./plugin";

set_chart_config = (labels, votes, voters) => {
   chart_config = {type: "bar",
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
    plugins: [chart_plugin],
  }

  return chart_config
};

export default set_chart_config;