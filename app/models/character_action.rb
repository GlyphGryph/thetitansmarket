class CharacterActionValidator < ActiveModel::Validator
  def validate(record)
    unless record.character.can_add_action?(record.action_id)
      record.errors[:character] << " does not have enough AP remaining to conduct to #{Action.find(record.action_id).name} this turn."
    end
  end
end

class CharacterAction < ActiveRecord::Base
  belongs_to :character
  validates_presence_of :character_id
  validates_presence_of :action_id
  include ActiveModel::Validations
  validates_with CharacterActionValidator
  before_create :default_attributes

  def default_attributes
    self.stored_vigor ||= 0
  end

  def get
    element = Action.find(self.action_id) 
    unless(element)
      raise "Could not find action for CharacterAction with id #{self.id}"
    end
    return element
  end

  def target
    return Action.find_target(self.target_type, self.target_id) 
  end

  def cost
    return self.get.cost(self.character, self.target)
  end

  def cost_remaining
    return self.cost - self.stored_vigor
  end

  def result
    return self.get.result(self.character, self.target)
  end
end
