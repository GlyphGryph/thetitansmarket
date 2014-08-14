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
