class CreateSpeechComponent < ActiveRecord::Migration
  def change
    create_table :speech_components do |t|
      t.integer :message_component_id
      t.text :quote
    end
  end
end
