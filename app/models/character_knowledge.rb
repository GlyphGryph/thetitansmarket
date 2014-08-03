class CharacterKnowledge < ActiveRecord::Base
  belongs_to :character
  validates_presence_of :character_id
  validates_presence_of :knowledge_id

  def get
    Knowledge.find(self.knowledge_id)
  end

  def learn
    self.known = true
    self.save!
  end
end
