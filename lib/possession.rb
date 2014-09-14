class Possession
  extend CollectionTracker
  attr_reader :id, :name, :description

  def initialize(id, params={})
    @id = id
    @name = params[:name] || "Name Error"
    @description = params[:description] || "Description Error"
    self.class.add(@id, self)
  end

  def type
    return "possession"
  end
end

# Load data
require 'data/possession/resources.rb'
require 'data/possession/land.rb'
require 'data/possession/artifacts.rb'
