class CreateProposals < ActiveRecord::Migration
  def change
    create_table :proposals do |t|
      t.integer :sender_id
      t.integer :receiver_id
      t.string :status
      t.integer :turn
      t.string :content_type
      t.integer :content_id

      t.timestamps
    end
  end
end
