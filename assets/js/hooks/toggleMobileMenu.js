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
    const MenuIsClosedIcon = document.getElementById("menu-closed");
    const MenuIsOpenedIcon = document.getElementById("menu-opened");

    this.menu.classList.toggle("hidden");
    if (!this.menu.classList.contains("hidden")) {
      this.body.style.overflow = "hidden";
      MenuIsClosedIcon.classList.remove("hidden")
      MenuIsOpenedIcon.classList.add("hidden")
    } else {
      this.body.style.overflow = "";
      MenuIsClosedIcon.classList.add("hidden");
      MenuIsOpenedIcon.classList.remove("hidden");
    }
  },
};

export default ToggleMobileMenu;