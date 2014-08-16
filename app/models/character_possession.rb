class CharacterPossession < ActiveRecord::Base
  belongs_to :character
  validates_presence_of :character_id
  validates_presence_of :possession_id
  attr_accessor :type, :contains

  def get
    element = Possession.find(self.possession_id)
    unless(element)
      raise "Could not find action for CharacterPossession #{self.id} with item type '#{self.possession_id}' for character #{self.character_id}"
    end
    return element
  end
end
