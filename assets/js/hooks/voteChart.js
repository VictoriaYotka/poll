import Chart from "chart.js/auto";
import set_chart_config from "../chart_js_config/chart_config";

let VoteChart = {
  mounted() {
    const ctx = this.el.querySelector("#voteChart").getContext("2d");
    const labels = JSON.parse(this.el.getAttribute("data-labels"));
    const votes = JSON.parse(this.el.getAttribute("data-votes"));
    const voters = JSON.parse(this.el.getAttribute("data-voters"));

    this.chart = new Chart(ctx, set_chart_config(labels, votes, voters));
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
