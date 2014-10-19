class Gesture
  extend CollectionTracker
  include Targetable
  attr_reader :id, :description, :name

  def initialize(id, params={})
    @id = id
    @name = params[:name] || "ERROR: Unknown Name"
    @description = params[:description] || "ERROR: UNKNOWN DESCRIPTION"
    @result = params[:result] || lambda do |viewer, actor, target|
      if(viewer==actor)
        return "You did something, but you're not sure what. You suspect this might be an ERROR."
      else
        return "#{viewer.name} did something, but you're not sure what. You suspect this might be an ERROR."
      end
    end
    @valid_targets = params[:valid_targets] || {}
    @requires_target = params[:requires_target] || false
    @target_prompt = params[:target_prompt] || "Targeting Prompt error"
    self.class.add(@id, self)
  end

  def result(viewer, actor, target)
    @result.call(viewer, actor, target)
  end
end

# Load data
require_dependency "data/gesture/all"
