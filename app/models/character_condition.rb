class CharacterCondition < ActiveRecord::Base
  belongs_to :character
  validates_presence_of :character_id
  validates_presence_of :condition_id

  def get
    element = Condition.find(self.condition_id)
    unless(element)
      raise "Could not find action for CharacterCondition with id #{self.id}"
    end
    return element
  end
end
