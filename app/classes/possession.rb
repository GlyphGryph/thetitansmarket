class Possession
  extend CollectionTracker
  attr_reader :id, :name, :description

  def initialize(id, params={})
    @id = id
    @name = params[:name] || "Name Error"
    @description = params[:description] || "Description Error"
    self.class.add(@id, self)
  end

  def type
    return "possession"
  end
end

# Format for new items
# 'id', {:name => 'Name', :description=>"Multi-word description." }

Possession.new("generic_object", 
  { :name=>"Perfectly Generic Object", 
    :description=>"The only notable thing about this object is its complete lack of notable features.", 
  }
)
Possession.new("food", 
  { :name=>"Food", 
    :description=>"This thing is, more or less, edible.", 
  }
)
Possession.new("seed", 
  { :name=>"Seeds", 
    :description=>"These seeds can be planted.", 
  }
)
Possession.new("dolait",
  { :name=>"Dolait Chunk",
    :description=>"This is a chunk of harvested dolait.",
  }
)
Possession.new("tomatunk",
  { :name=>"Tomatunk Block",
    :description=>"This is a block of gathered tomatunk.",
  }
)
Possession.new("wampoon",
  { :name=>"Wampoon Shard",
    :description=>"This is a shard of gathered wampoon.",
  }
)

Possession.new("wildlands", 
  { :name=>"Plot of Wilderness", 
    :description=>"A plot of land, overgrown by bushes, shrubs, brambles and nettles.", 
  }
)
Possession.new("field", 
  { :name=>"Empty Field.", 
    :description=>"A plot of cleared land.", 
  }
)
Possession.new("farm", 
  { :name=>"Farm Plot", 
    :description=>"A field full of food plants.", 
  }
)
Possession.new("dolait_source", 
  { :name=>"Dolait Grove", 
    :description=>"A thick grove of dolait.", 
  }
)
Possession.new("tomatunk_source", 
  { :name=>"Tomatunk Deposit", 
    :description=>"A marshy area with signs of tomatunk.", 
  }
)
Possession.new("wampoon_source", 
  { :name=>"Wampoon Deposit", 
    :description=>"A barren, rocky area with evidence of wampoon.", 
  }
)
