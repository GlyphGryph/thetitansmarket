class AddNameToBody < ActiveRecord::Migration
  def change
    add_column :bodies, :name, :string
  end
end
