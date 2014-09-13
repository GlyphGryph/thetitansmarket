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
