import Sortable from "../vendor/sortable";

const SortableHook = {
  mounted() {
    console.log("this.el", this.el);

    let sorter = new Sortable(this.el, {
      animation: 150,
      delay: 100,
      dragClass: "drag-item",
      ghostClass: "drag-ghost",
      forceFallback: true,
      onEnd: (e) => {
        let params = { old: e.oldIndex, new: e.newIndex, ...e.item.dataset };
        this.pushEventTo(this.el, "reposition", params);
      },
    });
  },
};

export default SortableHook;
