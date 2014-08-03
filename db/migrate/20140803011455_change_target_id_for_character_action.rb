class ChangeTargetIdForCharacterAction < ActiveRecord::Migration
  def up
    remove_column :character_actions, :target_id, :string
    add_column :character_actions, :target_id, :integer
  end

  def down
    remove_column :character_actions, :target_id, :integer
    add_column :character_actions, :target_id, :string
  end
end
