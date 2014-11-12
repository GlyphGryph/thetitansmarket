class CharacterBodyPart < ActiveRecord::Base
  belongs_to :character
  validates_presence_of :character
  validates_presence_of :body_part_id

  def get
    element = BodyPart.find(self.body_part_id)
    unless(element)
      raise "Could not find body part for CharacterPossession #{self.id} with item type '#{self.possession_id}' for character #{self.character_id}"
    end
    return element
  end

  def get_name(type=:singular)
    return self.get.name
  end
end
