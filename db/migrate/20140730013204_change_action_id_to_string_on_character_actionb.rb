class ChangeActionIdToStringOnCharacterActionb < ActiveRecord::Migration
  def up
    remove_column :character_actions, :action_id
    add_column :character_actions, :action_id, :string
  end
  def down
    remove_column :character_actions, :action_id
    add_column :character_actions, :action_id, :integer
  end
end
