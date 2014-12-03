class AddMaxHealthToBody < ActiveRecord::Migration
  def change
    add_column :bodies, :max_health, :integer
  end
end
