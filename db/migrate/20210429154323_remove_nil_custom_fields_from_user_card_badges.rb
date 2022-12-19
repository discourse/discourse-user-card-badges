# frozen_string_literal: true

class RemoveNilCustomFieldsFromUserCardBadges < ActiveRecord::Migration[6.0]
  def up
    execute <<~SQL
      DELETE FROM user_custom_fields
      WHERE name = 'card_image_badge_id' AND value IS NULL
    SQL
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
