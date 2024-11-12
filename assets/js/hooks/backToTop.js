let BackToTop = {
  mounted() {
    this.backToTopButton = document.getElementById("back-to-top");
    this.handleScroll = this.handleScroll.bind(this);
    this.scrollToTop = this.scrollToTop.bind(this);

    window.addEventListener("scroll", this.handleScroll);
    this.backToTopButton.addEventListener("click", this.scrollToTop);
  },

  destroyed() {
    window.removeEventListener("scroll", this.handleScroll);
    this.backToTopButton.removeEventListener("click", this.scrollToTop);
  },

  handleScroll() {
    if (window.scrollY > 300) {
      this.backToTopButton.classList.remove("hidden");
    } else {
      this.backToTopButton.classList.add("hidden");
    }
  },

  scrollToTop() {
    window.scrollTo({ top: 0, behavior: "smooth" });
  },
};

export default BackToTop;
