class CharacterCondition < ActiveRecord::Base
  belongs_to :character
  validates_presence_of :character_id
  validates_presence_of :condition_id

  def condition 
    Condition.find(self.condition_id)
  end
end
