class CreateGestureComponents < ActiveRecord::Migration
  def change
    create_table :gesture_components do |t|
      t.integer :actor_id
      t.integer :owner_id
      t.string :target_name
      t.boolean :owner_is_target

      t.timestamps
    end
  end
end
