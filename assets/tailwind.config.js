const plugin = require("tailwindcss/plugin");
const heroiconsPlugin = require("./tailwind-heroicons-plugin");

module.exports = {
  content: ["./js/**/*.js", "../lib/poll_web.ex", "../lib/poll_web/**/*.*ex"],
  theme: {
    extend: {
      fontFamily: {
        sans: ["Raleway", "Arial", "Helvetica", "sans-serif"],
        montserrat: ["Montserrat", "Arial", "Helvetica", "sans-serif"],
      },
      colors: {
        brand: "#FD4F00",
      },
    },
  },
  plugins: [
    require("@tailwindcss/forms"),
    plugin(({ addVariant }) => {
      addVariant("phx-no-feedback", [
        ".phx-no-feedback&",
        ".phx-no-feedback &",
      ]);
    }),
    plugin(({ addVariant }) => {
      addVariant("phx-click-loading", [
        ".phx-click-loading&",
        ".phx-click-loading &",
      ]);
    }),
    plugin(({ addVariant }) => {
      addVariant("phx-submit-loading", [
        ".phx-submit-loading&",
        ".phx-submit-loading &",
      ]);
    }),
    plugin(({ addVariant }) => {
      addVariant("phx-change-loading", [
        ".phx-change-loading&",
        ".phx-change-loading &",
      ]);
    }),
    heroiconsPlugin,
  ],
};
