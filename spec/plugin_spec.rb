# frozen_string_literal: true

require "rails_helper"

describe ::UserCardBadges do
  let(:user) { Fabricate(:user) }
  let(:badge) { Fabricate(:badge) }
  let(:image_upload) { Fabricate(:image_upload) }

  before do
    SiteSetting.user_card_badges_enabled = true
    UserCustomField.create!(user_id: user.id, name: "card_image_badge_id", value: badge.id)
    user.reload
  end

  it "adds card_badge to the UserCardSerializer" do
    serializer = UserCardSerializer.new(user)
    expect(serializer.card_badge).to eq(user.card_image_badge)
    expect(user.card_image_badge_id.to_i).to eq(badge.id)
  end

  it "adds card_image_badge to the UserSerializer if there is an image on the badge" do
    serializer = UserSerializer.new(user)
    expect(serializer.card_image_badge).to eq(nil)
    badge.update(image_upload: image_upload)
    expect(serializer.card_image_badge).to eq(image_upload)
  end
end
