import { fn } from "@ember/helper";
import DButton from "discourse/components/d-button";
import ComboBox from "discourse/select-kit/components/combo-box";
import { i18n } from "discourse-i18n";

export default <template>
  <section class="user-content">
    <form class="form-horizontal">
      <div class="control-group">
        <div class="controls">
          <h3>{{i18n "user.card_badge.title"}}</h3>
        </div>
      </div>

      <div class="control-group">
        <label class="control-label"></label>
        <div class="controls">
          <ComboBox
            class="user-card-badge-select"
            @value={{@controller.selectedUserBadgeId}}
            @nameProperty="badge.name"
            @content={{@controller.selectableUserBadges}}
            @onChange={{fn (mut @controller.selectedUserBadgeId)}}
          />
        </div>
      </div>

      <div class="control-group">
        <div class="controls">
          <DButton
            class="btn-primary"
            @disabled={{@controller.saving}}
            @label={{@controller.savingStatus}}
            @action={{@controller.save}}
          />

          {{#if @controller.saved}}{{i18n "saved"}}{{/if}}
        </div>
      </div>
    </form>
  </section>
</template>
