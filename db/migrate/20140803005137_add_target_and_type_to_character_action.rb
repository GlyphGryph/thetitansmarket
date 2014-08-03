class AddTargetAndTypeToCharacterAction < ActiveRecord::Migration
  def change
    add_column :character_actions, :target_type, :string
    add_column :character_actions, :target_id, :string
  end
end
