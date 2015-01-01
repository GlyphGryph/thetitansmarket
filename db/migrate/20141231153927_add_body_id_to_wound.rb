class AddBodyIdToWound < ActiveRecord::Migration
  def change
    add_column :wounds, :body_id, :integer
  end
end
