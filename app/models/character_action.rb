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

  def get
    Action.find(self.action_id)
  end

  def target
    if(self.target_type == "possession")
      return CharacterPossession.find(self.target_id)
    elsif(self.target_type == "condition")
      return CharacterCondition.find(self.target_id)
    elsif(self.target_type == "character")
      return Character.find(self.target_id)
    elsif(self.target_type == "knowledge" || self.target_type =="idea")
      return CharacterKnowledge.find(self.target_id)
    else
      raise "Invalid type provided. Could not find a rule to handle #{self.target_type}, #{self.target_id} for #{self.get.name}."
    end
  end
end
