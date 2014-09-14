class CharacterKnowledge < ActiveRecord::Base
  belongs_to :character
  validates_presence_of :character_id
  validates_presence_of :knowledge_id

  def get
    element = Knowledge.find(self.knowledge_id)
    unless(element)
      raise "Could not find knowledge '#{knowledge_id}' for CharacterKnowledge with id '#{self.id}'"
    end
    return element
  end

  def learn(amount=1)
    unless(known?)
      self.progress+=amount
      if(known?)
        self.get.learn_result(self.character, self)
      end
    end
    self.save!
  end

  def known?
    return self.progress >= self.max_progress
  end

  def max_progress
    self.get.components
  end
end
