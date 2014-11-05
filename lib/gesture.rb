class Gesture
  extend CollectionTracker
  include Targetable
  attr_reader :id, :description, :name

  def initialize(id, params={})
    @id = id
    @name = params[:name] || "ERROR: Unknown Name"
    @description = params[:description] || "ERROR: UNKNOWN DESCRIPTION"

    @outcomes = params[:outcomes] || {}

    @valid_targets = params[:valid_targets] || {}
    @requires_target = params[:requires_target] || false
    @target_prompt = params[:target_prompt] || "Targeting Prompt error"
    self.class.add(@id, self)
  end

  def result(viewer, actor, owner, owner_is_target, target_name)
    if(viewer == actor && actor == owner)
      state = @outcomes[:viewer_is][:actor_and_owner]
    elsif(viewer == actor)
      state = @outcomes[:viewer_is][:actor]
    elsif(viewer == owner)
      state = @outcomes[:viewer_is][:owner]
    else
      state = @outcomes[:viewer_is][:nothing]
    end

    base_string = owner_is_target ? state[:owner_is_target] : state[:owner_is_not_target]
    # If the owner is the actor, refer to the item as "their item", else it is "name's item"
    # This should be ignored in situations where it is "your item" since the string will not have an owner replacement value
    if(actor==owner)
      owned_name = "their"
    else
      owned_name = "#{owner.get_name}'s"
    end
    return base_string % {:viewer => viewer.get_name, :actor => actor.get_name, :owned => owned_name, :target => target_name}
  end
end

# Load data
require_dependency "data/gesture/all"
