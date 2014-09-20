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
    :difficulty => 25,
    :components => 5,
    :sources => {
      'knowledge' => ['gestures'],
    },
    :consider => "There has to be a better way to communicate than waving your arms around...",
    :research => "You discover the secrets of language!",
  }
)
Knowledge.new("basic_farming", 
  { :name=>"Farming",
    :description=>"You know how to clear, sow, and harvest the fields.",
    :difficulty => 30,
    :components => 4,
    :sources => {
      'possession' => ['food', 'wildlands'],
      'condition' => ['hunger'],
    },
    :consider => "You wonder if you could grow your own food, given the opportunity.",
    :research => "You discover the secrets of agriculture!",
  }
)
Knowledge.new("basic_dolait", 
  { :name=>"Dolait Harvesting",
    :description=>"You know how to harvest dolait chunks.",
    :difficulty => 10,
    :components => 2,
    :sources => {
      'possession' => ['dolait_source','dolait'],
    },
    :consider => "You could probably get more of this substance without too much difficulty...",
    :research => "You figure out the basics of harvesting dolait.",
  }
)
Knowledge.new("basic_tomatunk", 
  { :name=>"Tomatunk Gathering",
    :description=>"You know how to find tomatunk blocks.",
    :difficulty => 20,
    :components => 2,
    :sources => {
      'possession' => ['tomatunk_source','tomatunk'],
    },
    :consider => "You could probably get more of this substance with sharp eyes and a bit of luck...",
    :research => "You figure out the basics of gathering tomatunk.",
  }
)
Knowledge.new("basic_wampoon", 
  { :name=>"Wampoon Gathering",
    :description=>"You know how to find wampoon shards",
    :difficulty => 50,
    :components => 2,
    :sources => {
      'possession' => ['wampoon_source','wampoon'],
    },
    :consider => "You could probably get more of this substance with sharp eyes and a lot of luck...",
    :research => "You figure out the basics of gathering wampoon.",
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
    :difficulty => 50,
    :components => 3,
    :sources => {
      'possession' => ['tomatunk','dolait'],
    },
    :consider => "This substance has some interesting properties. There must be a use for it.",
    :research => "You think you might be able to build some sort of tool out of the right materials. You have a few ideas already.",
  }
)
Knowledge.new("craft_basket", 
  { :name=>"Craft Basket",
    :description=>"Craft a basket from dolait.",
    :difficulty => 25,
    :components => 3,
    :sources => {
      'knowledge' => ['basic_crafting'],
    },
    :consider => "With a bit of dolait, you think you'll be able to figure out how to make a basket to aid in your gathering.",
    :research => "Stripped and woven, dolait can be used to craft a useful carrying container.",
  }
)
Knowledge.new("craft_cutter", 
  { :name=>"Craft Simple Cutter",
    :description=>"Craft a simple cutting tool from tomatunk.",
    :difficulty => 25,
    :components => 3,
    :sources => {
      'knowledge' => ['basic_crafting'],
    },
    :consider => "With a bit of tomatunk, you think you'll be able to figure out how to make a simple cutting tool to aid in your harvesting and clearing.",
    :research => "With the aid of a slab of stone, you've figured out a way to chip and grind away at the tomatunk until it forms a sharp edge opposite a safe grip.",
  }
)
Knowledge.new("craft_shaper", 
  { :name=>"Craft Simple Shaper",
    :description=>"Craft a simple shaping tool from dolait and tomatunk. You know how to make several varieties.",
    :difficulty => 25,
    :components => 5,
    :sources => {
      'knowledge' => ['basic_crafting'],
    },
    :consider => "Tomatunk and dolait are useful materials, but difficult to work with. You think you could build some tools to make cracking and warping less likely to occur when crafting tools.",
    :research => "An assortment of splitting and grinding tools should make the process of shaping future tools more reliable.",
  }
)
Knowledge.new("craft_toy",
  { :name =>"Craft Simple Toy",
    :description=>"Craft a simple toy to stave of weariness.",
    :difficulty => 25,
    :components => 3,
    :sources => {
      'condition' => ['weariness'],
    },
    :consider => "You think you could use some strips of dolait to make simple toys to entertain yourself or others.",
    :research => "It probably won't last forever, and you might well get bored of it before it falls apart, but you think you can make a variety of small toys with what you've discovered.",
  }
)
