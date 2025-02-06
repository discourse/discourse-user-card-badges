import Controller from "@ember/controller";
import EmberObject, { action } from "@ember/object";
import { service } from "@ember/service";
import { ajax } from "discourse/lib/ajax";
import computed from "discourse/lib/decorators";
import Badge from "discourse/models/badge";
import { i18n } from "discourse-i18n";

export default class PreferencesCardBadgeController extends Controller {
  @service dialog;

  saving = false;
  saved = false;

  @computed("model")
  filteredList(model) {
    return model.filterBy("badge.image");
  }

  @computed("filteredList")
  selectableUserBadges(filteredList) {
    return [
      EmberObject.create({
        badge: Badge.create({ name: i18n("badges.none") }),
      }),
      ...filteredList.uniqBy("badge.name"),
    ];
  }

  @computed("saving")
  savingStatus(saving) {
    return saving ? "saving" : "save";
  }

  @computed("selectedUserBadgeId")
  selectedUserBadge(selectedUserBadgeId) {
    return this.selectableUserBadges.findBy(
      "id",
      parseInt(selectedUserBadgeId, 10)
    );
  }

  @action
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
        this.dialog.alert(i18n("generic_error"));
      });
  }
}
