class CreateBodies < ActiveRecord::Migration
  def change
    create_table :bodies do |t|
      t.integer :health
      t.boolean :dead

      t.timestamps
    end
  end
end
