class AddApAndMaxApToCharacter < ActiveRecord::Migration
  def change
    add_column :characters, :ap, :integer
    add_column :characters, :max_ap, :integer
  end
end
