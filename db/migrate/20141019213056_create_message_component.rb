class CreateMessageComponent < ActiveRecord::Migration
  def change
    create_table :message_components do |t|
      t.string :message_id
      t.text :body
      t.boolean :is_speech
    end
  end
end
