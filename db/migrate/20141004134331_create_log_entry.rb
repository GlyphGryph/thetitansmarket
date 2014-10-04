class CreateLogEntry < ActiveRecord::Migration
  def change
    create_table :log_entries do |t|
      t.integer :log_id
      t.text :body
      t.string :type
    end
  end
end
