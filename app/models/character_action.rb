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

  def name
    Action.find(self.action_id).name
  end

  def action
    Action.find(self.action_id)
  end

  def target
    if(self.target_type == "possession")
      return CharacterPossession.find(self.target_id)
    elsif(self.target_type == "condition")
      return CharacterCondition.find(self.target_id)
    elsif(self.target_type == "character")
      return Character.find(self.target_id)
    elsif(self.target_type == "knowledge")
      return CharacterKnowledge.find(self.target_id)
    else
      return OpenStruct.new(:name=>"Invalid Type")
    end
  end
end
