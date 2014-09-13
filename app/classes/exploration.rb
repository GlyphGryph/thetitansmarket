class Exploration 
  extend CollectionTracker
  attr_reader :id, :name

  def initialize(id, params={})
    @id = id
    @name = params[:name] || "Name Error"
    @result = params[:result] || lambda { |character| return "Exploration Result Error" }
    self.class.add(@id, self)
  end

  def result(character)
    @result.call(character)
  end

  def type
    return "exploration"
  end
end

# Load data
require 'data/exploration/all.rb'
