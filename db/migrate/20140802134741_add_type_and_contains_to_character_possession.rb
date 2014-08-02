class AddTypeAndContainsToCharacterPossession < ActiveRecord::Migration
  def change
    add_column :character_possessions, :variant, :string
    add_column :character_possessions, :contains, :string
  end
end
