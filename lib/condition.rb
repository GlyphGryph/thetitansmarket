class Condition
  extend CollectionTracker
  attr_reader :id, :name, :description

  def initialize(id, params={})
    @id = id
    @name = params[:name] || "Name Error"
    @description = params[:description] || "Description Error"
    @result = params[:result] || lambda { |character| return "Condition Result Error" }
    self.class.add(@id, self)
  end

  def result(character)
    @result.call(character)
  end

  def type
    return "condition"
  end
end 

# Load data
require_dependency "data/condition/all"
