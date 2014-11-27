class AddAttributesToWorldVisitor < ActiveRecord::Migration
  def change
    add_column :world_visitors, :health, :integer
    add_column :world_visitors, :anger, :integer
    add_column :world_visitors, :fear, :integer
  end
end
