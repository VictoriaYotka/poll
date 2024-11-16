let FlashTimeout = {
  mounted() {
    const flashGroup = document.getElementById("flash_container");

    if (flashGroup) {
      setTimeout(() => {
        flashGroup.style.display = "none";
      }, 5000);
    }
  },
};

export default FlashTimeout;
