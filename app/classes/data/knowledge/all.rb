# Format for new items
# 'id', {:name => 'Name', :description=>"Multi-word description." }

Knowledge.new("cognition", 
  { :name=>"Cognition", 
    :description=>"You possess the ability to Ponder life's mysteries.", 
  }
)
Knowledge.new("play", 
  { :name=>"Play", 
    :description=>"You know how to have fun.", 
  }
)
Knowledge.new("gestures", 
  { :name=>"Gestures", 
    :description=>"You can engage in basic communication with others.", 
  }
)
Knowledge.new("language", 
  { :name=>"Language", 
    :description=>"You can engage in basic communication with others.", 
    :components => 5,
  }
)
Knowledge.new("basic_farming", 
  { :name=>"Farming", 
    :description=>"You know how to clear, sow, and harvest the fields.", 
  }
)
Knowledge.new("basic_dolait", 
  { :name=>"Dolait Harvesting", 
    :description=>"You know how to harvest dolait chunks.", 
  }
)
Knowledge.new("basic_tomatunk", 
  { :name=>"Tomatunk Gathering", 
    :description=>"You know how to find tomatunk blocks.", 
  }
)
Knowledge.new("basic_wampoon", 
  { :name=>"Wampoon Gathering", 
    :description=>"You know how to find wampoon shards", 
  }
)
Knowledge.new("basic_crafting", 
  { :name=>"Basic Crafting", 
    :description=>"You know the basics of shaping tomatunk and dolait.", 
    :learn_result=> lambda do |character, character_action|
      character.consider('craft_basket')
      character.consider('craft_cutter')
      character.consider('craft_shaper')
    end,
  }
)
Knowledge.new("craft_basket", 
  { :name=>"Craft Basket", 
    :description=>"Craft a basket from dolait.", 
  }
)
Knowledge.new("craft_cutter", 
  { :name=>"Craft Simple Cutter", 
    :description=>"Craft a simple cutting tool from tomatunk.", 
  }
)
Knowledge.new("craft_shaper", 
  { :name=>"Craft Simple Shaper", 
    :description=>"Craft a simple shaping tool from dolait and tomatunk.", 
  }
)
Knowledge.new("craft_toy",
  { :name =>"Craft Simple Toy",
    :description=>"Craft a simple toy to stave of weariness."
  }
)
