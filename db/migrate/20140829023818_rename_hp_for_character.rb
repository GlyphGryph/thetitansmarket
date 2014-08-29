class RenameHpForCharacter < ActiveRecord::Migration
  def change
    rename_column :characters, :hp, :health
    rename_column :characters, :max_hp, :max_health
  end
end
