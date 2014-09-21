class CreateTradePossessions < ActiveRecord::Migration
  def change
    create_table :trade_possessions do |t|
      t.integer :trade_id
      t.boolean :offered
      t.integer :quantity
      t.string :possession_id
      t.string :possession_variant
    end
  end
end
