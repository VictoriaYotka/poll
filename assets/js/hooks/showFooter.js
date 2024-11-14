let ShowFooter = {
  mounted() {
    const footer = this.el;
    let showTimeout;

    const toggleFooterVisibility = () => {
      const isScrollable = document.body.scrollHeight > window.innerHeight;

      if (!isScrollable) {
        footer.classList.remove("hidden");
        return;
      }

      const scrolledToBottom =
        window.innerHeight + window.scrollY >= document.body.scrollHeight - 1;

      if (scrolledToBottom) {
        clearTimeout(showTimeout);

        showTimeout = setTimeout(() => {
          footer.classList.remove("hidden");
        }, 200);
      } else {
        clearTimeout(showTimeout);
        footer.classList.add("hidden");
      }
    };

    toggleFooterVisibility();

    window.addEventListener("scroll", toggleFooterVisibility);
    window.addEventListener("resize", toggleFooterVisibility);
  },

  destroyed() {
    window.removeEventListener("scroll", this.toggleFooterVisibility);
    window.removeEventListener("resize", this.toggleFooterVisibility);
  },
};

export default ShowFooter;
