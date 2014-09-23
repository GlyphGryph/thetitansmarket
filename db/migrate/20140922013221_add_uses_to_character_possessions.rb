class AddUsesToCharacterPossessions < ActiveRecord::Migration
  def change
    add_column :character_possessions, :charges, :integer
  end
end
