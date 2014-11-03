class RemoveBodyAndIsSpeechFromMessageComponent < ActiveRecord::Migration
  def change
    remove_column :message_components, :body, :text
    remove_column :message_components, :is_speech, :boolean
  end
end
