class Gesture
  extend CollectionTracker
  include Targetable
  attr_reader :id, :description, :name
  
  @@outcomes = {
    :viewer_is => {
      :actor_and_owner => {
        :owner_is_target => "You %{verb} yourself.",
        :owner_is_not_target => "You %{verb} your %{target}",
      },
      :actor => {
        :owner_is_target => "You %{verb} %{target}",
        :owner_is_not_target => "You %{verb} %{owned} %{target}",
      },
      :owner => {
        :owner_is_target => "%{actor} %{verb} you.",
        :owner_is_not_target => "%{actor} %{verb} your %{target}",
      },
      :nothing => {
        :owner_is_target => "%{actor} %{verb} %{target}",
        :owner_is_not_target => "%{actor} %{verb} %{owned} %{target}",
      }
    },
  }

  def initialize(id, params={})
    @id = id
    @name = params[:name] || "ERROR: Unknown Name"
    @description = params[:description] || "ERROR: UNKNOWN DESCRIPTION"
    
    @second_person = params[:second_person] || "something"
    @third_person = params[:third_person] || "somethings"
    @addendum = params[:addendum] || nil
    
    @valid_targets = params[:valid_targets] || {}
    @requires_target = params[:requires_target] || false
    @target_prompt = params[:target_prompt] || "Targeting Prompt error"
    self.class.add(@id, self)
  end

  def result(viewer, actor, owner, owner_is_target, target_name)
    if(viewer == actor && actor == owner)
      verb = @second_person
      state = @@outcomes[:viewer_is][:actor_and_owner]
    elsif(viewer == actor)
      verb = @second_person
      state = @@outcomes[:viewer_is][:actor]
    elsif(viewer == owner)
      verb = @third_person
      state = @@outcomes[:viewer_is][:owner]
    else
      verb = @third_person
      state = @@outcomes[:viewer_is][:nothing]
    end

    base_string = owner_is_target ? state[:owner_is_target] : state[:owner_is_not_target]
    # If the owner is the actor, refer to the item as "their item", else it is "name's item"
    # This should be ignored in situations where it is "your item" since the string will not have an owner replacement value
    if(actor==owner)
      owned_name = "their"
    else
      owned_name = "#{owner.get_name}'s"
    end
    result_string = base_string % {:viewer => viewer.get_name, :actor => actor.get_name, :owned => owned_name, :target => target_name, :verb => verb}
    if(@addendum)
      result_string+= " #{@addendum}"
    end
    return result_string
  end
end

# Load data
require_dependency "data/gesture/all"
