class AddReadyToCharacter < ActiveRecord::Migration
  def change
    add_column :characters, :ready, :boolean
  end
end
