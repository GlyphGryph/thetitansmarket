Gesture.new("wave",
  { :name => "Wave", 
    :description => "Wave at the other person.", 

    # actor viewer owner target
    :viewer_is_actor_string => "You wave at %{target}",
    :viewer_is_target_string => "%{actor} waves at you.",
    :viewer_is_both_string => "You wave at yourself.",
    :viewer_is_neither_string => "%{actor} waves at %{target}.",

    :viewer_is_actor_and_owner => "You wave at yourself.",
    :view_is_neither_actor_is_owner => "%{actor} waves at themselves."
    :viewer_is_actor_not_owner => "You wave at %{owner}",
    :viewer_is_owner_not_actor => "%{actor} waves at you.",
    :viewer_is_neither_actor_now_owner => "%{actor} waves at %{owner}.",

  }
)

Gesture.new("point",
  { :name => "Point", 
    :description => "Point at something.", 

    :viewer_is => {
      :actor_and_owner => {
        :owner_is_target => "You point at yourself."
        :owner_is_not_target => "You point at your %{target}"
      }
      :actor => {
        :owner_is_target => "You point at %{target}"
        :owner_is_not_target => "You point at %{owner}'s %{target}"
      }
      :owner => {
        :owner_is_target => "%{actor} points at you."
        :owner_is_not_target => "%{actor} points at your %{target}"
      }
      :nothing => {
        :owner_is_target => "%{actor} points at %{targer}"
        :owner_is_not_target => "%{actor} points at %{owner}'s %{target}"
      }
    }

    :target_prompt => "What would you like to point at?",
    :requires_target => true,
    :valid_targets => {:possession=>['all'], :character=>['all'], :body=>['all']},
  }
)
