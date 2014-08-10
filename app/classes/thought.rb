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
end

Thought.new("basic_farming",
  { :sources => {
      'knowledge' => [],
      'possession' => ['food', 'wildlands'],
      'condition' => ['hunger'],
    },
    :consider => "You wonder if you could grow your own food, given the opportunity.",
    :research => "You dicover the secrets of agriculture!"
  }
)

Thought.new("language",
  { :sources => {
      'knowledge' => ['gestures'],
      'possession' => [],
      'condition' => [],
    },
    :consider => "There has to be a better way to communicate than waving your arms around...",
    :research => "You dicover the secrets of language!"
  }
)