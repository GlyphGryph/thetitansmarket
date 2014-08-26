class AddStoredApToCharacterAction < ActiveRecord::Migration
  def change
    add_column :character_actions, :stored_ap, :integer
  end
end
