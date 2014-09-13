# Format for new items
# 'id', {:name => 'Name', :description=>"Multi-word description."
# :result => lamda describing the code that will execute each turn for those with this condition
Condition.new("hunger",
  { :name=>"Hunger", 
    :description=>"You're in the mood for food.", 
    :result => lambda { |character| 
      if(character.eat)
        return "You gobble up a unit of food."
      else 
        character.change_health(-3)
        character.change_resolve(-1)
        return "You suffer from starvation."
      end
    },
  }
)

Condition.new("weariness",
  { :name=>"Weariness", 
    :description=>"Life keeps on keeping on.", 
    :result => lambda { |character| 
      character.change_resolve(-1)
      return "As time passes, your feel a weight settle on your soul."
    },
  }
)
Condition.new("resilience",
  { :name=>"Resilience", 
    :description=>"Pull yourself together, kid.", 
    :result => lambda { |character| 
      character.change_health(1)
      return "You feel your body recovering from the damage it's sustained."
    },
  }
)
Condition.new("pure_grit",
  { :name=>"Pure Grit", 
    :description=>"You're holding yourself together with nothing but willpower and determination at this point, but it can't last much longer...", 
    :result => lambda { |character| 
      return "This is a result."
    },
  }
)
Condition.new("nihilism",
  { :name=>"Nihilism", 
    :description=>"Is it even worth going on, if this is all life is?", 
    :result => lambda { |character| 
      character.change_health(-2)
      return "You feel your body falling apart, but can't bring yourself to care."
    },
  }
)
