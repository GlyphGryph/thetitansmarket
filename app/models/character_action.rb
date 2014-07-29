class CharacterAction < ActiveRecord::Base
  belongs_to :character
  belongs_to :action
  validates_presence_of :character_id
  validates_presence_of :action_id

  def name
    action.name
  end
end
