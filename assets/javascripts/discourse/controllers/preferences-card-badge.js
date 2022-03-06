import I18n from "I18n";
import Badge from "discourse/models/badge";
import computed from "discourse-common/utils/decorators";
import { ajax } from "discourse/lib/ajax";
import Controller from "@ember/controller";
import EmberObject from "@ember/object";

export default Controller.extend({
  saving: false,
  saved: false,

  @computed("model")
  filteredList(model) {
    return model.filterBy("badge.image");
  },

  @computed("filteredList")
  selectableUserBadges(filteredList) {
    return [
      EmberObject.create({
        badge: Badge.create({ name: I18n.t("badges.none") }),
      }),
      ...filteredList.uniqBy("badge.name"),
    ];
  },

  @computed("saving")
  savingStatus(saving) {
    return saving ? "saving" : "save";
  },

  @computed("selectedUserBadgeId")
  selectedUserBadge(selectedUserBadgeId) {
    return this.selectableUserBadges.findBy(
      "id",
      parseInt(selectedUserBadgeId, 10)
    );
  },

  actions: {
    save() {
      this.setProperties({ saved: false, saving: true });

      ajax(`${this.user.path}/preferences/card-badge`, {
        type: "PUT",
        data: { user_badge_id: this.selectedUserBadgeId },
      })
        .then(() => {
          this.setProperties({
            saved: true,
            saving: false,
            "user.card_image_badge": this.get("selectedUserBadge.badge.image"),
          });
        })
        .catch(() => {
          this.set("saving", false);
          bootbox.alert(I18n.t("generic_error"));
        });
    },
  },
});
