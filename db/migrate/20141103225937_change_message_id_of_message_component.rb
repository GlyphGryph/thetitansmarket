class ChangeMessageIdOfMessageComponent < ActiveRecord::Migration
  def change
    remove_column :message_components, :message_id, :string
    add_column :message_components, :message_id, :integer
  end
end
