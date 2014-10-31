Gesture.new("wave",
  { :name=>"Wave", 
    :description=>"Wave at the other person.", 
    :result => lambda { |viewer, actor, target|
      if(viewer==actor)
        return "You wave at #{target.get.name}."
      else
        return "#{viewer.get.name} waves at you."
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
        return "#{actor.get.name} points at you."
      else
        return "#{actor.get.name} points at #{target.get.name}"
      end     
    },
    :requires_target => true,
    :valid_targets => {:possession=>['all'], :character=>['all'], :body=>['all']},
    :target_prompt => "What would you like to point at?",
  }
)
