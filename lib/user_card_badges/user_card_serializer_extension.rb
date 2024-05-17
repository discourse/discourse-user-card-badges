# frozen_string_literal: true

module UserCardBadges
  module UserCardSerializerExtension
    extend ActiveSupport::Concern

    prepended { has_one :card_badge, embed: :object, serializer: BadgeSerializer }
  end
end
