class Knowledge
  extend CollectionTracker
  attr_reader :id, :name, :description

  def initialize(id, params={})
    @id = id
    @name = params[:name] || "Name Error"
    @description = params[:description] || "Description Error"
    self.class.add(@id, self)
  end
end

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
  }
)
Knowledge.new("basic_farming", 
  { :name=>"Farming", 
    :description=>"You know how to clear, sow, and harvest the fields.", 
  }
)
