class CharacterKnowledge < ActiveRecord::Base
  belongs_to :character
  validates_presence_of :character_id
  validates_presence_of :knowledge_id

  def get
    element = Knowledge.find(self.knowledge_id)
    unless(element)
      raise "Could not find action for CharacterKnowledge with id #{self.id}"
    end
    return element
  end

  def learn
    self.known = true
    self.save!
  end
end
