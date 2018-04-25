import computed from 'ember-addons/ember-computed-decorators';
import { ajax } from 'discourse/lib/ajax';
import BadgeSelectController from "discourse/mixins/badge-select-controller";

export default Ember.Controller.extend(BadgeSelectController, {
  @computed('model')
  filteredList(model) {
    return model.filter(b => !Ember.isEmpty(b.get('badge.image')));
  },

  actions: {
    save: function() {
      this.setProperties({ saved: false, saving: true });

      ajax(this.get('user.path') + "/preferences/card-badge", {
        type: "PUT",
        data: { user_badge_id: this.get('selectedUserBadgeId') }
      }).then(() => {
        this.setProperties({
          saved: true,
          saving: false,
          "user.card_image_badge": this.get('selectedUserBadge.badge.image')
        });
      }).catch(() => {
        this.set('saving', false);
        bootbox.alert(I18n.t('generic_error'));
      });
    }
  }
});
