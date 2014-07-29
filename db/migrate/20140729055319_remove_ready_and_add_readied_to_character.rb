class RemoveReadyAndAddReadiedToCharacter < ActiveRecord::Migration
  def change
    remove_column :characters, :ready, :boolean
    add_column :characters, :readied, :boolean
  end
end
