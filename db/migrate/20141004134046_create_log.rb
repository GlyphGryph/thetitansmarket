class CreateLog < ActiveRecord::Migration
  def change
    create_table :logs do |t|
      t.string :owner_type
      t.integer :owner_id
    end
  end
end
