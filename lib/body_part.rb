class BodyPart
  extend CollectionTracker
  attr_reader :id, :name

  def initialize(id, params={})
    @id = id
    @name = id
    self.class.add(@id, self)
  end
end

# Load data
require_dependency "data/body_part/all"
