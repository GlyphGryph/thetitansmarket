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
    :consider => "You wonder if you could do anything interesting with this substance...",
    :research => "You figure out the basics of harvesting and working with dolait.",
  }
)
