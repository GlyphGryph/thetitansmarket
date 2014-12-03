class AddWorldIdToBody < ActiveRecord::Migration
  def change
    add_column :bodies, :world_id, :integer
  end
end
