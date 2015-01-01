class RemoveOwnerFromWound < ActiveRecord::Migration
  def change
    remove_column :wounds, :owner_id, :integer
    remove_column :wounds, :owner_type, :string
  end
end
