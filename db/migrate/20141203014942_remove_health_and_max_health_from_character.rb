class RemoveHealthAndMaxHealthFromCharacter < ActiveRecord::Migration
  def change
    remove_column :characters, :health, :integer
    remove_column :characters, :max_health, :integer
  end
end
