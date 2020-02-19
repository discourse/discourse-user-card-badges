import { withPluginApi } from "discourse/lib/plugin-api";
import computed from "discourse-common/utils/decorators";

function modifyUserCardContents(api) {
  api.modifyClass("component:user-card-contents", {
    classNameBindings: ["hasCardBadgeImage"],

    @computed("user.card_badge.image")
    hasCardBadgeImage(image) {
      return image && image.indexOf("fa-") !== 0;
    }
  });
}

export default {
  name: "user-card-badges",

  initialize() {
    withPluginApi("0.8.19", api => {
      modifyUserCardContents(api);
    });
  }
};
