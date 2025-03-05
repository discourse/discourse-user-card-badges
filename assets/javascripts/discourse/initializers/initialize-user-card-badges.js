import { withPluginApi } from "discourse/lib/plugin-api";

function modifyUserCardContents(api) {
  api.modifyClass(
    "component:user-card-contents",
    (Superclass) =>
      class extends Superclass {
        get classNames() {
          const result = [...super.classNames];
          const image = this.get("user.card_badge.image");
          if (image && !image.startsWith("fa-")) {
            result.push("has-card-badge-image");
          }
          return result;
        }
      }
  );
}

export default {
  name: "user-card-badges",

  initialize() {
    withPluginApi("0.8.19", (api) => {
      modifyUserCardContents(api);
    });
  },
};
