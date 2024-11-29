import UserBadge from "discourse/models/user-badge";
import RestrictedUserRoute from "discourse/routes/restricted-user";

export default class PreferencesCardBadge extends RestrictedUserRoute {
  showFooter = true;

  model() {
    return UserBadge.findByUsername(this.modelFor("user").get("username"));
  }

  setupController(controller, model) {
    controller.set("model", model);
    controller.set("user", this.modelFor("user"));

    model.forEach(function (userBadge) {
      if (
        userBadge.get("badge.id") === controller.get("user.card_image_badge_id")
      ) {
        controller.set("selectedUserBadgeId", userBadge.get("id"));
      }
    });
  }
}
