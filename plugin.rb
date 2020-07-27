# frozen_string_literal: true

# name: discourse-user-card-badges
# about: User Card Badges Plugin
# version: 0.1
# authors: Neil Lalonde
# url: https://github.com/discourse/discourse-user-card-badges

enabled_site_setting :user_card_badges_enabled

register_asset 'stylesheets/user-card-badges.scss'

after_initialize do
  if respond_to?(:allow_public_user_custom_field)
    allow_public_user_custom_field "card_image_badge_id"
  else
    whitelist_public_user_custom_field "card_image_badge_id"
  end

  add_to_class(:user, :card_image_badge_id) do
    self.custom_fields['card_image_badge_id']
  end

  add_to_class(:user, :card_image_badge) do
    badge_id = self.card_image_badge_id
    badge_id ? Badge.find_by_id(badge_id) : nil
  end

  require_dependency 'user_card_serializer'

  class ::UserCardSerializer
    has_one :card_badge, embed: :object, serializer: BadgeSerializer
  end

  add_to_serializer(:user_card, :card_badge, false) do
    object.card_image_badge
  end

  add_to_serializer(:user, :card_image_badge, false) do
    card_badge&.image
  end

  add_to_serializer(:user, :card_image_badge_id) do
    card_badge&.id
  end

  add_to_serializer(:user, :include_card_image_badge?, false) { can_edit }
  add_to_serializer(:user, :include_card_image_badge_id?, false) { can_edit }

  module ::UserCardBadges
    class Engine < ::Rails::Engine
      engine_name 'user_card_badges'
      isolate_namespace UserCardBadges
    end
  end

  require_dependency 'application_controller'

  class UserCardBadges::UserCardBadgeController < ::ApplicationController

    def show
    end

    def update
      user = fetch_user_from_params
      guardian.ensure_can_edit!(user)

      user_badge = UserBadge.find_by(id: params[:user_badge_id].to_i)
      if user_badge && user_badge.user == user && user_badge.badge.image.present?
        current_user.custom_fields['card_image_badge_id'] = user_badge.badge.id
      else
        current_user.custom_fields['card_image_badge_id'] = nil
      end
      current_user.save

      render body: nil
    end

  end

  Discourse::Application.routes.prepend do
    mount ::UserCardBadges::Engine, at: '/'
  end

  UserCardBadges::Engine.routes.draw do
    username_route_format = defined?(RouteFormat) ? RouteFormat.username : USERNAME_ROUTE_FORMAT

    %w{users u}.each do |user_root|
      get "#{user_root}/:username/preferences/card-badge" => "user_card_badge#show", constraints: { username: username_route_format }
      put "#{user_root}/:username/preferences/card-badge" => "user_card_badge#update", constraints: { username: username_route_format }
    end
  end
end
