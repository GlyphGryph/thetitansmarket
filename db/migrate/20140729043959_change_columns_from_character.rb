class ChangeColumnsFromCharacter < ActiveRecord::Migration
  def change
    remove_column :characters, :mhp, :integer
    remove_column :characters, :mhappy, :integer
    add_column :characters, :max_happy, :integer
    add_column :characters, :max_hp, :integer
  end
end
