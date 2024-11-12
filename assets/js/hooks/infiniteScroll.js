let InfiniteScroll = {
  mounted() {
    this.handleScroll = this.handleScroll.bind(this);
    window.addEventListener("scroll", this.handleScroll);
  },

  destroyed() {
    window.removeEventListener("scroll", this.handleScroll);
  },

  handleScroll() {
    const scrollPosition = window.scrollY + window.innerHeight;
    const documentHeight = document.documentElement.scrollHeight;

    if (scrollPosition + 100 >= documentHeight) {
      this.pushEvent("load_more_polls", {});
    }
  },
};

export default InfiniteScroll;