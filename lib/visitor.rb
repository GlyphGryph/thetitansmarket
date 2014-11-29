class Visitor
  extend CollectionTracker
  attr_reader :id, :name, :description, :starting_health, :starting_anger, :starting_fear

  def initialize(id, params={})
    @id = id
    @name = params[:name] || "Name Error"
    @description = params[:description] || "Description Error"
    @result = params[:result] || lambda { |instance, character| return false}
    @attacked = params[:attacked] || lambda { |instance, character| return false}
    @scared = params[:scared] || lambda { |instance, character| return false}
    @butchered = params[:butchered] || lambda { |instance, character| return false}
    @starting_health = params[:health]
    @starting_anger = params[:anger]
    @starting_fear = params[:fear]
    self.class.add(@id, self)
  end

  def execute(character_condition)
    @result.call(character_condition)
  end

  def attacked(instance, character)
    @attacked.call(instance, character)
  end

  def scared(instance, character)
    @scared.call(instance, character)
  end

  def butchered(instance, character)
    @butchered.call(instance, character)
  end
end 

# Load data
require_dependency "data/visitor/all"
