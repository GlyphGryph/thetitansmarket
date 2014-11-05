class AddGestureIdColumnToGestureComponent < ActiveRecord::Migration
  def change
    add_column :gesture_components, :gesture_id, :string
  end
end
