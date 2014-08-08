class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.text :title
      t.text :body

      t.timestamps
    end
  end
end
