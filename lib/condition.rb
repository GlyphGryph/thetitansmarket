class Condition
  extend CollectionTracker
  attr_reader :id, :name, :description

  def initialize(id, params={})
    @id = id
    @name = params[:name] || "Name Error"
    @description = params[:description] || "Description Error"
    @result = params[:result] || lambda { |character| return "Condition Result Error" }
    @active = params[:active] || lambda { |character| return true }
    self.class.add(@id, self)
  end

  def result(character_condition)
    @result.call(character_condition)
  end

  def type
    return "condition"
  end

  def active?(character_condition)
    return @active.call(character_condition)
  end
end 

# Load data
require_dependency "data/condition/all"
