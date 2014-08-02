class CharacterKnowledge < ActiveRecord::Base
  belongs_to :character
  validates_presence_of :character_id
  validates_presence_of :knowledge_id

  def knowledge
    Knowledge.find(self.knowledge_id)
  end
end
