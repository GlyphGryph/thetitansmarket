class Visitor
  extend CollectionTracker
  attr_reader :id, :name, :description

  def initialize(id, params={})
    @id = id
    @name = params[:name] || "Name Error"
    @description = params[:description] || "Description Error"
    @result = params[:result] || lambda { |instance, character| return false}
    @attacked = params[:attacked] || lambda { |instance, character| return false}
    @scared = params[:scared] || lambda { |instance, character| return false}
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
end 

# Load data
require_dependency "data/visitor/all"
