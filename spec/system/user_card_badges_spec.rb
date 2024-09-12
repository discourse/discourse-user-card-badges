# frozen_string_literal: true

RSpec.describe "User card badges plugin", type: :system do
  before { SiteSetting.user_card_badges_enabled = true }
  fab!(:user)
  fab!(:topic) { Fabricate(:topic, user: user) }
  fab!(:badge) { Fabricate(:badge, image_upload: Fabricate(:upload)) }
  let!(:user_badge) { BadgeGranter.grant(badge, user) }

  it "works" do
    sign_in user
    visit "/my/preferences/profile"
    find(".pref-card-badge a[href]").click

    try_until_success do
      expect(current_url).to eq("#{Discourse.base_url}/u/#{user.username}/preferences/card-badge")
    end

    expect(page).to have_css(".user-card-badge-select")
    selector = PageObjects::Components::SelectKit.new(".user-card-badge-select")
    selector.select_row_by_value(user_badge.id)
    find(".user-content .btn-primary").click

    find("#site-logo").click

    try_until_success { expect(current_url).to eq("#{Discourse.base_url}/") }

    find("[data-user-card='#{user.username}']").click

    expect(page).to have_css("a.user-card-badge-link img[src='#{badge.image_upload.url}']")
  end
end
