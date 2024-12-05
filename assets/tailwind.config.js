const plugin = require("tailwindcss/plugin");
const heroiconsPlugin = require("./tailwind-heroicons-plugin");

module.exports = {
  content: [
    "./js/**/*.js",
    "./assets/**/*.html",
    "./assets/**/*.js",
    "../lib/poll_web.ex",
    "../lib/poll_web/**/*.*ex",
  ],
  theme: {
    extend: {
      fontFamily: {
        sans: ["Raleway", "Arial", "Helvetica", "sans-serif"],
        montserrat: ["Montserrat", "Arial", "Helvetica", "sans-serif"],
      },
      colors: {
        main_accent: {
          200: "#C7D2FE",
          300: "#A5B4FC",
          500: "#6366F1",
          600: "#4F46E5",
          800: "#3730A3",
        },
        bright_accent: "#F59E0B",
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
