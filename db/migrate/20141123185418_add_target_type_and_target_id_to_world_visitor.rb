class AddTargetTypeAndTargetIdToWorldVisitor < ActiveRecord::Migration
  def change
    add_column :world_visitors, :target_type, :string
    add_column :world_visitors, :target_id, :integer
  end
end
