// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "../vendor/topbar"

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()

let Hooks = {};

Hooks.ScrollControl = {
    mounted() {
      let menuToggleButton = document.getElementById("menu-toggle");
      let body = document.body;
      let menu = document.getElementById("mobile-menu");

      menuToggleButton.addEventListener("click", () => {
        if (menu.classList.contains("hidden")) {
          // Menu is being opened, block scroll
          body.style.overflow = "hidden";
        } else {
          // Menu is being closed, allow scroll again
          body.style.overflow = "";
        }
      });
    }
  }

Hooks.InfiniteScroll = {
  mounted() {
    window.addEventListener("scroll", this.handleScroll.bind(this));
  },

  destroyed() {
    window.removeEventListener("scroll", this.handleScroll.bind(this));
  },

  handleScroll() {
    const scrollPosition = window.scrollY + window.innerHeight;
    const documentHeight = document.documentElement.scrollHeight;

    if (scrollPosition + 100 >= documentHeight) {
      this.pushEvent("load_more_polls", {});
      window.scrollY - window.innerHeight;
    }
  },
};

  Hooks.BackToTop = {
    mounted() {
      let backToTopButton = document.getElementById("back-to-top");

      window.addEventListener("scroll", () => {
        if (window.scrollY > 300) {
          backToTopButton.classList.remove("hidden");
        } else {
          backToTopButton.classList.add("hidden");
        }
      });

      backToTopButton.addEventListener("click", () => {
        window.scrollTo({ top: 0, behavior: "smooth" });
      });
    }
  }

let csrfToken = document
  .querySelector("meta[name='csrf-token']")
  .getAttribute("content");

let liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: { _csrf_token: csrfToken },
  hooks: Hooks,
});

// Connect to LiveSocket
liveSocket.connect();

window.liveSocket = liveSocket;
