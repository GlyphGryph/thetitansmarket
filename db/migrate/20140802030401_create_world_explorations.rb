class CreateWorldExplorations < ActiveRecord::Migration
  def change
    create_table :world_explorations do |t|
      t.integer :world_id
      t.string :exploration_id

      t.timestamps
    end
  end
end
