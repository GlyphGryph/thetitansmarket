class Plant
  extend CollectionTracker
  attr_reader :id, :plant_name, :food_name, :seed_name

  def initialize(id, params={})
    @id = id
    @plant_name = params[:plant_name] || "ERROR: UNKNOWN"
    @food_name = params[:food_name] || "ERROR: UNKNOWN"
    @seed_name = params[:seed_name] || "ERROR: UNKNOWN"
    self.class.add(@id, self)
  end

  def type
    return "plant"
  end
end

# Load data
require 'data/plant/all.rb'
