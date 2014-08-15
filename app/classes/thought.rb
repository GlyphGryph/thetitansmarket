class Thought
  extend CollectionTracker
  attr_reader :id, :sources, :consider, :research

  def initialize(id, params={})
    @id = id
    @consider = params[:consider] || "Error, no consideration found"
    @sources = params[:sources] || {} 
    @research = params[:research] || "Error, no research found"
    self.class.add(@id, self)
  end

  def type
    return "thought"
  end
end

Thought.new("basic_farming",
  { :sources => {
      'possession' => ['food', 'wildlands'],
      'condition' => ['hunger'],
    },
    :consider => "You wonder if you could grow your own food, given the opportunity.",
    :research => "You dicover the secrets of agriculture!",
  }
)

Thought.new("language",
  { :sources => {
      'knowledge' => ['gestures'],
    },
    :consider => "There has to be a better way to communicate than waving your arms around...",
    :research => "You dicover the secrets of language!",
  }
)

Thought.new('basic_dolait',
  { :sources => {
      'possession' => ['dolait_source','dolait'],
    },
    :consider => "You could probably get more of this substance without too much difficulty...",
    :research => "You figure out the basics of harvesting dolait.",
  }
)
Thought.new('basic_tomatunk',
  { :sources => {
      'possession' => ['tomatunk_source','tomatunk'],
    },
    :consider => "You could probably more of this substance with sharp eyes and a bit of luck...",
    :research => "You figure out the basics of gathering tomatunk.",
  }
)
Thought.new('basic_wampoon',
  { :sources => {
      'possession' => ['wampoon_source','wampoon'],
    },
    :consider => "You could probably more of this substance with sharp eyes and a lot of luck...",
    :research => "You figure out the basics of gathering wampoon.",
  }
)
Thought.new('basic_wampoon',
  { :sources => {
      'possession' => ['wampoon_source','wampoon'],
    },
    :consider => "You could probably more of this substance with sharp eyes and a lot of luck...",
    :research => "You figure out the basics of gathering wampoon.",
  }
)
Thought.new('basic_crafting',
  { :sources => {
      'possession' => ['tomatunk','dolait'],
    },
    :consider => "This substance has some interesting properties. There must be a use for it.",
    :research => "You think you might be able to build some sort of tool out of the right materials. You have a few ideas already.",
  }
)
Thought.new('craft_basket',
  { :sources => {
      'knowledge' => ['basic_crafting'],
    },
    :consider => "With a bit of dolait, you think you'll be able to figure out how to make a basket to aid in your gathering.",
    :research => "Stripped and woven, dolait can be used to craft a useful carrying container."
  }
)
Thought.new('craft_cutter',
  { :sources => {
      'knowledge' => ['basic_crafting'],
    },
    :consider => "With a bit of tomatunk, you think you'll be able to figure out how to make a simple cutting tool to aid in your harvesting and clearing.",
    :research => "With the aid of a slab of stone, you've figured out a way to chip and grind away at the tomatunk until it forms a sharp edge opposite a safe grip."
  }
)
Thought.new('craft_shaper',
  { :sources => {
      'knowledge' => ['basic_crafting'],
    },
    :consider => "Tomatunk and dolait are useful materials, but difficult to work with. You think you could build some tools to make cracking and warping less likely to occur when crafting tools.",   
    :research => "An assortment of splitting and grinding tools that should make the process of shaping future tools more reliable."
  }
)
