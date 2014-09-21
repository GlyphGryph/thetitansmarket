class CreatePossessionVariants < ActiveRecord::Migration
  def change
    create_table :possession_variants do |t|
      t.string :key
      t.string :possession_id
      t.string :singular_name
      t.string :plural_name
    end
  end
end
