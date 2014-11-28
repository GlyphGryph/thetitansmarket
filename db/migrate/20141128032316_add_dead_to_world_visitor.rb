class AddDeadToWorldVisitor < ActiveRecord::Migration
  def change
    add_column :world_visitors, :dead, :boolean, :default => false
  end
end
