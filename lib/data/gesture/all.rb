Gesture.new("wave",
  { :name => "Wave", 
    :description => "Wave at the other person.", 
    
    :outcomes => {
      :viewer_is => {
        :actor_and_owner => {
          :owner_is_target => "You wave at yourself.",
          :owner_is_not_target => "You wave at your %{target}",
        },
        :actor => {
          :owner_is_target => "You wave at %{target}",
          :owner_is_not_target => "You wave at %{owned} %{target}",
        },
        :owner => {
          :owner_is_target => "%{actor} waves at you.",
          :owner_is_not_target => "%{actor} waves at your %{target}",
        },
        :nothing => {
          :owner_is_target => "%{actor} waves at %{targer}",
          :owner_is_not_target => "%{actor} waves at %{owned} %{target}",
        }
      }
    },
  }
)

Gesture.new("point",
  { :name => "Point", 
    :description => "Point at something.", 
    
    :outcomes => {
      :viewer_is => {
        :actor_and_owner => {
          :owner_is_target => "You point at yourself.",
          :owner_is_not_target => "You point at your %{target}",
        },
        :actor => {
          :owner_is_target => "You point at %{target}",
          :owner_is_not_target => "You point at %{owned} %{target}",
        },
        :owner => {
          :owner_is_target => "%{actor} points at you.",
          :owner_is_not_target => "%{actor} points at your %{target}",
        },
        :nothing => {
          :owner_is_target => "%{actor} points at %{targer}",
          :owner_is_not_target => "%{actor} points at %{owned} %{target}",
        }
      },
    },

    :target_prompt => "What would you like to point at?",
    :requires_target => true,
    :valid_targets => {:possession=>['all'], :character=>['all'], :body=>['all']},
  }
)
