class RemoveBodyFromMessage < ActiveRecord::Migration
  def change
    remove_column :messages, :body, :text
  end
end
