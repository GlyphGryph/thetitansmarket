class Gesture
  extend CollectionTracker
  include Targetable
  attr_reader :id, :description, :name

  def initialize(id, params={})
    @id = id
    @names = params[:name] || "ERROR: Unknown Name"
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
end

Gesture.new("wave",
  { :name=>"Wave", 
    :description=>"Wave at the other person.", 
    :result => lambda { |viewer, actor, target|
      if(viewer==actor)
        return "You wave at #{target.name}."
      else
        return "#{viewer.name} waves at you."
      end     
    },
  }
)

Gesture.new("point",
  { :name=>"Point", 
    :description=>"Point at something.", 
    :result => lambda { |viewer, actor, target|
      if(viewer==actor)
        return "You point at #{target.name}."
      elsif(viewer==target)
        return "#{actor.name} points at you."
      else
        return "#{actor.name} points at #{target.name}"
      end     
    },
    :requires_target => true,
    :valid_targets => {"possession"=>['all'], "condition"=>['all'], "knowledge"=>['all'], "character"=>['all']},
    :target_prompt => "What would you like to point at?",
  }
)
