class AddActivityIdToInteraction < ActiveRecord::Migration
  def change
    add_column :interactions, :activity_id, :string
  end
end
