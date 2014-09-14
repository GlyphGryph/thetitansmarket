class Thought
  extend CollectionTracker
  attr_reader :id, :sources, :consider, :research

  def initialize(id, params={})
    @id = id
    @consider = params[:consider] || "Error, no consideration found"
    @sources = params[:sources] || {} 
    @research = params[:research] || "Error, no research found"
    self.class.add(@id, self)
  end

  def type
    return "thought"
  end
end

# Load data
require_dependency "data/thought/all"
