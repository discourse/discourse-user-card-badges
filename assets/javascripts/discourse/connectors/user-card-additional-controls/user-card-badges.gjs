import Component from "@ember/component";
import { LinkTo } from "@ember/routing";
import { classNames, tagName } from "@ember-decorators/component";

@tagName("div")
@classNames("user-card-additional-controls-outlet", "user-card-badges")
export default class UserCardBadges extends Component {
  <template>
    {{#if this.user.card_badge}}
      <LinkTo
        @route="badges.show"
        @model={{this.user.card_badge}}
        class="card-badge"
      >
        <img
          src={{this.user.card_badge.image}}
          alt={{this.user.card_badge.name}}
        />
      </LinkTo>
    {{/if}}
  </template>
}
