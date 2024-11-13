let ToggleMobileMenu = {
  mounted() {
    this.menuToggleButton = document.getElementById("menu-toggle");
    this.body = document.body;
    this.menu = document.getElementById("mobile-menu");

    this.toggleMenu = this.toggleMenu.bind(this);
    this.menuToggleButton.addEventListener("click", this.toggleMenu);
  },

  destroyed() {
    this.menuToggleButton.removeEventListener("click", this.toggleMenu);
  },

  toggleMenu() {
    this.menu.classList.toggle("hidden");
    if (!this.menu.classList.contains("hidden")) {
      this.body.style.overflow = "hidden";
      this.menuToggleButton.innerHTML = `<svg width="20" height="20" fill="white" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M23.954 21.03l-9.184-9.095 9.092-9.174-2.832-2.807-9.09 9.179-9.176-9.088-2.81 2.81 9.186 9.105-9.095 9.184 2.81 2.81 9.112-9.192 9.18 9.1z"/></svg>`;
    } else {
      this.body.style.overflow = "";
      this.menuToggleButton.innerHTML = `<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg" width="24" height="24" fill="white">
          <path d="m12 16.495c1.242 0 2.25 1.008 2.25 2.25s-1.008 2.25-2.25 2.25-2.25-1.008-2.25-2.25 1.008-2.25 2.25-2.25zm0 1.5c.414 0 .75.336.75.75s-.336.75-.75.75-.75-.336-.75-.75.336-.75.75-.75zm0-8.25c1.242 0 2.25 1.008 2.25 2.25s-1.008 2.25-2.25 2.25-2.25-1.008-2.25-2.25 1.008-2.25 2.25-2.25zm0 1.5c.414 0 .75.336.75.75s-.336.75-.75.75-.75-.336-.75-.75.336-.75.75-.75zm0-8.25c1.242 0 2.25 1.008 2.25 2.25s-1.008 2.25-2.25 2.25-2.25-1.008-2.25-2.25 1.008-2.25 2.25-2.25zm0 1.5c.414 0 .75.336.75.75s-.336.75-.75.75-.75-.336-.75-.75.336-.75.75-.75z" />
        </svg>`;
    }
  },
};

export default ToggleMobileMenu;