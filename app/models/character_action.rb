class CharacterAction < ActiveRecord::Base
  belongs_to :character
  validates_presence_of :character_id
  validates_presence_of :action_id

  def name
    Action.find(self.action_id).name
  end
end
