class Gesture
  extend CollectionTracker
  include Targetable
  attr_reader :id, :description, :name

  def initialize(id, params={})
    @id = id
    @name = params[:name] || "ERROR: Unknown Name"
    @description = params[:description] || "ERROR: UNKNOWN DESCRIPTION"

    @viewer_is_actor_string = params[:viewer_is_actor_string] || "You do something unspeakable to %target"
    @viewer_is_target_string = params[:viewer_is_target_string] || "%actor does something unspeakable to you."
    @viewer_is_both_string = params[:viewer_is_both_string] || "You do something unspeakable to yourself."
    @viewer_is_neither_string = params[:viewer_is_neither_string] || "%actor does something unspeakable to %target."

    @valid_targets = params[:valid_targets] || {}
    @requires_target = params[:requires_target] || false
    @target_prompt = params[:target_prompt] || "Targeting Prompt error"
    self.class.add(@id, self)
  end

  def result(viewer, actor, owner, target_name)
    base_string = "invalid"
    return base_string % {:viewer => viewer.get.name, :actor => actor.get.name, :target => target.get.name}
  end
end

# Load data
require_dependency "data/gesture/all"
