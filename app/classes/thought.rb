class Thought
  extend CollectionTracker
  attr_reader :id, :sources, :description

  def initialize(id, params={})
    @id = id
    @description = params[:description]
    @sources = params[:sources]
    self.class.add(@id, self)
  end
end

Thought.new("basic_farming",
  { :sources => {
      'knowledge' => [],
      'possession' => ['food', 'wildlands'],
      'condition' => ['hunger'],
    },
    :description => "You wonder if you could grow your own food, given the opportunity.",
  }
)

Thought.new("language",
  { :sources => {
      'knowledge' => ['gestures'],
      'possession' => [],
      'condition' => [],
    },
    :description => "There has to be a better way to communicate than waving your arms around...",
  }
)
