class AddOwnerToBody < ActiveRecord::Migration
  def change
    add_column :bodies, :owner_id, :integer
    add_column :bodies, :owner_type, :string
  end
end
