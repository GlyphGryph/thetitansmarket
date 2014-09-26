class AddNutritionToCharacter < ActiveRecord::Migration
  def change
    add_column :characters, :nutrition, :integer
  end
end
