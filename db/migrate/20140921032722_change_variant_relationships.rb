class ChangeVariantRelationships < ActiveRecord::Migration
  def change
    remove_column :character_possessions, :variant, :string
    remove_column :trade_possessions, :possession_variant, :string
    add_column :character_possessions, :possession_variant_id, :integer
    add_column :trade_possessions, :possession_variant_id, :integer
  end
end
