import Badge from "discourse/models/badge";
import computed from "discourse-common/utils/decorators";
import { ajax } from "discourse/lib/ajax";

export default Ember.Controller.extend({
  saving: false,
  saved: false,

  disableSave: Ember.computed.alias("saving"),

  @computed("model")
  filteredList(model) {
    return model.filter(b => !Ember.isEmpty(b.get("badge.image")));
  },

  @computed("filteredList")
  selectableUserBadges(items) {
    items = _.uniq(items, false, function(e) {
      return e.get("badge.name");
    });
    items.unshiftObject(
      Ember.Object.create({
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
    this.selectableUserBadges.forEach(function(userBadge) {
      if (userBadge.get("id") === selectedUserBadgeId) {
        selectedUserBadge = userBadge;
      }
    });
    return selectedUserBadge;
  },

  actions: {
    save: function() {
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
