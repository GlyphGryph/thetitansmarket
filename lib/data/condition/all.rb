# Format for new items
# 'id', {:name => 'Name', :description=>"Multi-word description."
# :result => lamda describing the code that will execute each turn for those with this condition
Condition.new("hunger",
  { :name=>"Hunger", 
    :description=>"You're in the mood for food.", 
    :result => lambda { |character_condition| 
      character = character_condition.character
      if(character_condition.active?)
        character.current_history.make_entry("passive", "You suffer from starvation.")
        character.change_health(-3)
        character.change_resolve(-1)
      else
        character.current_history.make_entry("passive", "You feel hungry again.")
        character.nutrition = 0
        character.save!
      end
    },
    :active => lambda { |character_condition|
      return character_condition.character.nutrition <= 0
    }
  }
)

Condition.new("weariness",
  { :name=>"Weariness", 
    :description=>"Life keeps on keeping on.", 
    :result => lambda { |character_condition| 
      character = character_condition.character
      character.current_history.make_entry("passive", "As time passes, your feel a weight settle on your soul.")
      character = character_condition.character
      character.change_resolve(-1)
    },
  }
)
Condition.new("resilience",
  { :name=>"Resilience", 
    :description=>"Pull yourself together, kid.", 
    :result => lambda { |character_condition| 
      character = character_condition.character
      character.current_history.make_entry("passive", "You feel your body recovering from the damage it's sustained.")
      character = character_condition.character
      character.change_health(1)
    },
  }
)
Condition.new("pure_grit",
  { :name=>"Pure Grit", 
    :description=>"You're holding yourself together with nothing but willpower and determination at this point, but it can't last much longer...", 
    :result => lambda { |character_condition| 
    },
  }
)
Condition.new("nihilism",
  { :name=>"Nihilism", 
    :description=>"Is it even worth going on, if this is all life is?", 
    :result => lambda { |character_condition| 
      character = character_condition.character
      character.current_history.make_entry("passive", "You feel your body falling apart, but can't bring yourself to care.")
      character = character_condition.character
      character.change_health(-2)
    },
  }
)
