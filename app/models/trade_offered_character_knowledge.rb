class TradeOfferedCharacterKnowledge < ActiveRecord::Base
  belongs_to :trade
  validates_presence_of :duration

  def get
    element = Knowledge.find(self.knowledge_id)
    unless(element)
      raise "Could not find #{self.knowledge_id} action for TradeKnowledge with id #{self.id}"
    end
    return element
  end
end
