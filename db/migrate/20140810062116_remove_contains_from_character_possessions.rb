class RemoveContainsFromCharacterPossessions < ActiveRecord::Migration
  def up
    remove_column :character_possessions, :contains
  end

  def down
    add_column :character_possessions, :contains, :string
  end
end
