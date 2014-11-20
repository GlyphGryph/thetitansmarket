class CreateWorldVisitor < ActiveRecord::Migration
  def change
    create_table :world_visitors do |t|
      t.integer :world_id
      t.string :visitor_id
    end
  end
end
