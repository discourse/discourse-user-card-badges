import Component from "@ember/component";
import { LinkTo } from "@ember/routing";
import { classNames, tagName } from "@ember-decorators/component";
import icon from "discourse/helpers/d-icon";
import { i18n } from "discourse-i18n";

@tagName("div")
@classNames("user-preferences-profile-outlet", "user-card-badges")
export default class UserCardBadges extends Component {
  <template>
    {{#if this.siteSettings.user_card_badges_enabled}}
      <div class="control-group pref-card-badge">
        <label class="control-label">{{i18n "user.card_badge.title"}}</label>
        <div class="controls">
          <div class="card-image-preview">
            {{#if this.model.card_image_badge}}
              <img
                src={{this.model.card_image_badge.url}}
                alt={{this.user.card_badge.name}}
              />
            {{else}}
              {{i18n "user.card_badge.none"}}
            {{/if}}
          </div>
          <LinkTo
            @route="preferences.card-badge"
            class="btn btn-small pad-left no-text"
          >{{icon "pencil"}}</LinkTo>
        </div>
      </div>
    {{/if}}
  </template>
}
