class AddActorIdToSpeechComponents < ActiveRecord::Migration
  def change
    add_column :speech_components, :actor_id, :integer
  end
end
