const chart_plugin = {
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

export default chart_plugin;