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
          :owner_is_target => "%{actor} waves at %{target}",
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
          :owner_is_target => "%{actor} points at %{target}",
          :owner_is_not_target => "%{actor} points at %{owned} %{target}",
        }
      },
    },

    :target_prompt => "What would you like to point at?",
    :requires_target => true,
    :valid_targets => {:possession=>['all'], :character=>['all'], :body=>['all']},
  }
)

Gesture.new("wink",
  { :name => "Wink", 
    :description => "Wink at someone.", 
    
    :outcomes => {
      :viewer_is => {
        :actor_and_owner => {
          :owner_is_target => "You wink at yourself.",
          :owner_is_not_target => "You wink at your %{target}",
        },
        :actor => {
          :owner_is_target => "You wink at %{target}",
          :owner_is_not_target => "You wink at %{owned} %{target}",
        },
        :owner => {
          :owner_is_target => "%{actor} winks at you.",
          :owner_is_not_target => "%{actor} winks at your %{target}",
        },
        :nothing => {
          :owner_is_target => "%{actor} winkss at %{target}",
          :owner_is_not_target => "%{actor} winks at %{owned} %{target}",
        }
      },
    },

    :target_prompt => "Who would you like to wink at?",
    :requires_target => true,
    :valid_targets => {:character=>['all']},
  }
)

Gesture.new("hug",
  { :name => "Hug", 
    :description => "Hug someone.", 
    
    :outcomes => {
      :viewer_is => {
        :actor_and_owner => {
          :owner_is_target => "You hug yourself.",
          :owner_is_not_target => "You hug your %{target}",
        },
        :actor => {
          :owner_is_target => "You hug %{target}",
          :owner_is_not_target => "You hug %{owned} %{target}",
        },
        :owner => {
          :owner_is_target => "%{actor} hugs at you.",
          :owner_is_not_target => "%{actor} hugs your %{target}",
        },
        :nothing => {
          :owner_is_target => "%{actor} hugs %{target}",
          :owner_is_not_target => "%{actor} hugs %{owned} %{target}",
        }
      },
    },

    :target_prompt => "Who would you like to wink at?",
    :requires_target => true,
    :valid_targets => {:character=>['all']},
  }
)

Gesture.new("gnaw",
  { :name => "Gnaw", 
    :description => "Gnaw on something.", 
    
    :outcomes => {
      :viewer_is => {
        :actor_and_owner => {
          :owner_is_target => "You gnaw on yourself.",
          :owner_is_not_target => "You gnaw on your %{target}",
        },
        :actor => {
          :owner_is_target => "You gnaw on %{target}",
          :owner_is_not_target => "You gnaw on %{owned} %{target}",
        },
        :owner => {
          :owner_is_target => "%{actor} gnaw on you.",
          :owner_is_not_target => "%{actor} gnaw on your %{target}",
        },
        :nothing => {
          :owner_is_target => "%{actor} gnaw on %{target}",
          :owner_is_not_target => "%{actor} gnaws on %{owned} %{target}",
        }
      },
    },

    :target_prompt => "What would you like to gnaw on?",
    :requires_target => true,
    :valid_targets => {:possession=>['all'], :character=>['all'], :body=>['all']},
  }
)
