# Format for new items
# 'id', {:name => 'Name', :description=>"Multi-word description."
# :result => lamda describing the code that will execute each turn for those with this condition
Exploration.new("nothing", 
  { :name=>"Nothing of Value", 
    :result => lambda { |character| 
      return "Your explorations have turned up nothing of value."
    },
  }
)
Exploration.new("wildlands_claim", 
  { :name=>"Claimed Land", 
    :result => lambda { |character| 
      CharacterPossession.new(:character_id => character.id, :possession_id => "wildlands").save!
      return "You claim a plot of promising looking wilderness."
    },
  }
)
Exploration.new("animal_attack", 
  { :name=>"Attacked!", 
    :result => lambda { |character| 
      character.change_health(0-rand(1..5))
      return "You're attacked by a dangerous wild animal and injured!"
    },
  }
)
Exploration.new("artifact", 
  { :name=>"An Ancient Artifact...", 
    :result => lambda { |character| 
      CharacterPossession.new(:character_id => character.id, :possession_id => "generic_object").save!
      return "You've discovered a Perfectly Generic Object."
    },
  }
)
Exploration.new("dolait_claim", 
  { :name=>"a Dolait Grove", 
    :result => lambda { |character| 
      CharacterPossession.new(:character_id => character.id, :possession_id => "dolait_source").save!
      return "You've discovered a Dolait Grove."
    },
  }
)
Exploration.new("tomatunk_claim", 
  { :name=>"a Tomatunk Deposit", 
    :result => lambda { |character| 
      CharacterPossession.new(:character_id => character.id, :possession_id => "tomatunk_source").save!
      return "You've discovered a Tomatunk Deposit."
    },
  }
)
Exploration.new("wampoon_claim", 
  { :name=>"a Wampoon Deposit", 
    :result => lambda { |character| 
      CharacterPossession.new(:character_id => character.id, :possession_id => "wampoon_source").save!
      return "You've discovered a Wampoon Deposit."
    },
  }
)
