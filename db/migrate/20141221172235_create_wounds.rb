class CreateWounds < ActiveRecord::Migration
  def change
    create_table :wounds do |t|
      t.string :wound_template_id
      t.integer :owner_id
      t.string :owner_type

      t.timestamps
    end
  end
end
