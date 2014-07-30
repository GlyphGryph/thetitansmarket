class AddHistoryToCharacter < ActiveRecord::Migration
  def change
    add_column :characters, :history, :text
  end
end
