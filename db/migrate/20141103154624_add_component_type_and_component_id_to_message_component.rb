class AddComponentTypeAndComponentIdToMessageComponent < ActiveRecord::Migration
  def change
    add_column :message_components, :element_type, :string
    add_column :message_components, :element_id, :integer
  end
end
