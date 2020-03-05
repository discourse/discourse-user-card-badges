import Badge from "discourse/models/badge";
import computed from "discourse-common/utils/decorators";
import { ajax } from "discourse/lib/ajax";
import Controller from "@ember/controller";
import EmberObject from "@ember/object";
import { isPresent } from "@ember/utils";

export default Controller.extend({
  saving: false,
  saved: false,

  @computed("model")
  filteredList(model) {
    return model.filter(b => isPresent(b.get("badge.image")));
  },

  @computed("filteredList")
  selectableUserBadges(items) {
    items = _.uniq(items, false, e => e.get("badge.name"));
    items.unshiftObject(
      EmberObject.create({
        badge: Badge.create({ name: I18n.t("badges.none") })
      })
    );
    return items;
  },

  @computed("saving")
  savingStatus(saving) {
    return saving ? I18n.t("saving") : I18n.t("save");
  },

  @computed("selectedUserBadgeId")
  selectedUserBadge(selectedUserBadgeId) {
    selectedUserBadgeId = parseInt(selectedUserBadgeId);
    let selectedUserBadge = null;
    this.selectableUserBadges.forEach(userBadge => {
      if (userBadge.get("id") === selectedUserBadgeId) {
        selectedUserBadge = userBadge;
      }
    });
    return selectedUserBadge;
  },

  actions: {
    save() {
      this.setProperties({ saved: false, saving: true });

      ajax(this.get("user.path") + "/preferences/card-badge", {
        type: "PUT",
        data: { user_badge_id: this.get("selectedUserBadgeId") }
      })
        .then(() => {
          this.setProperties({
            saved: true,
            saving: false,
            "user.card_image_badge": this.get("selectedUserBadge.badge.image")
          });
        })
        .catch(() => {
          this.set("saving", false);
          bootbox.alert(I18n.t("generic_error"));
        });
    }
  }
});
