class CharacterTrait < ActiveRecord::Base
  belongs_to :character
  validates_presence_of :character_id
  validates_presence_of :trait_id

  def get
    element = Trait.find(self.trait_id)
    unless(element)
      raise "Could not find action for CharacterCondition with id #{self.id}"
    end
    return element
  end

  def get_name(type=nil)
    self.get.name
  end
end
