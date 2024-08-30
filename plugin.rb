# frozen_string_literal: true

# name: discourse-user-card-badges
# about: User Card Badges Plugin
# version: 0.1
# authors: Neil Lalonde
# url: https://github.com/discourse/discourse-user-card-badges

enabled_site_setting :user_card_badges_enabled

register_asset "stylesheets/user-card-badges.scss"

after_initialize do
  module ::UserCardBadges
    PLUGIN_NAME = "discourse-user-card-badges"

    class Engine < ::Rails::Engine
      engine_name PLUGIN_NAME
      isolate_namespace UserCardBadges
    end
  end

  require_relative "lib/user_card_badges/user_card_serializer_extension"

  if respond_to?(:allow_public_user_custom_field)
    allow_public_user_custom_field "card_image_badge_id"
  else
    whitelist_public_user_custom_field "card_image_badge_id"
  end

  add_to_class(:user, :card_image_badge_id) { self.custom_fields["card_image_badge_id"] }

  add_to_class(:user, :card_image_badge) do
    badge_id = self.card_image_badge_id
    badge_id ? Badge.find_by_id(badge_id) : nil
  end

  reloadable_patch { UserCardSerializer.prepend(UserCardBadges::UserCardSerializerExtension) }

  add_to_serializer(:user_card, :card_badge, respect_plugin_enabled: false) do
    object.card_image_badge
  end

  add_to_serializer(:user, :card_image_badge, respect_plugin_enabled: false) do
    card_badge&.image_upload
  end

  add_to_serializer(:user, :card_image_badge_id) { card_badge&.id }

  add_to_serializer(:user, :include_card_image_badge?, respect_plugin_enabled: false) { can_edit }
  add_to_serializer(:user, :include_card_image_badge_id?, respect_plugin_enabled: false) do
    can_edit
  end

  class UserCardBadges::UserCardBadgeController < ::ApplicationController
    requires_plugin UserCardBadges::PLUGIN_NAME

    def show
    end

    def update
      user = fetch_user_from_params
      guardian.ensure_can_edit!(user)

      user_badge = UserBadge.find_by(id: params[:user_badge_id].to_i)
      if user_badge && user_badge.user == user && user_badge.badge.image_upload.present?
        current_user.custom_fields["card_image_badge_id"] = user_badge.badge.id
      else
        current_user.custom_fields.delete("card_image_badge_id")
      end

      current_user.save

      render body: nil
    end
  end

  Discourse::Application.routes.prepend { mount ::UserCardBadges::Engine, at: "/" }

  UserCardBadges::Engine.routes.draw do
    username_route_format = defined?(RouteFormat) ? RouteFormat.username : USERNAME_ROUTE_FORMAT

    %w[users u].each do |user_root|
      get "#{user_root}/:username/preferences/card-badge" => "user_card_badge#show",
          :constraints => {
            username: username_route_format,
          }
      put "#{user_root}/:username/preferences/card-badge" => "user_card_badge#update",
          :constraints => {
            username: username_route_format,
          }
    end
  end
end
