class Possession
  extend CollectionTracker
  attr_reader :id, :name, :description, :max_charges

  def initialize(id, params={})
    @id = id
    @name = params[:name] || "Name Error"
    @variant_name = params[:variant_name] || lambda { |key| return @name }
    @description = params[:description] || "Description Error"
    @max_charges = params[:max_charges] || 0
    @age = params[:age] || lambda{|character_possession| return AgeResult.new(:silent) }
    self.class.add(@id, self)
  end

  def type
    return "possession"
  end

  def age(character_possession)
    return @age.call(character_possession)
  end

  def variant_name(key)
    @variant_name.call(key)
  end
end

class AgeResult
  attr_accessor :message, :status

  def initialize(status, message="Error: No Message Provided")
    # Valid status results are currently :silent and :loud
    @status = status
    @message = message
  end
end

# Load data
require_dependency "data/possession/resources"
require_dependency "data/possession/land"
require_dependency "data/possession/artifacts"
