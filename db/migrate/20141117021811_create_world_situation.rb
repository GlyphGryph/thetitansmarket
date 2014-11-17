class CreateWorldSituation < ActiveRecord::Migration
  def change
    create_table :world_situations do |t|
      t.integer :world_id
      t.string :situation_id
      t.integer :duration
    end
  end
end
