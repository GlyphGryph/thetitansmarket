class Visitor
  extend CollectionTracker
  attr_reader :id, :name, :description

  def initialize(id, params={})
    @id = id
    @name = params[:name] || "Name Error"
    @description = params[:description] || "Description Error"
    @result = params[:result] || lambda { |instance| return false}
    self.class.add(@id, self)
  end

  def execute(character_condition)
    @result.call(character_condition)
  end

  def attacked(instance, character)
    character.record("important", "You attack the creature!")
  end

  def scared(instance, character)
    character.record("important", "You shout at the creature!")
  end
end 

# Load data
require_dependency "data/visitor/all"
