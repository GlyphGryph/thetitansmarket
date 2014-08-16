class Knowledge
  extend CollectionTracker
  attr_reader :id, :name, :description

  def initialize(id, params={})
    @id = id
    @name = params[:name] || "Name Error"
    @description = params[:description] || "Description Error"
    @learn_result = params[:learn_result] || lambda {|character, character_action| return true}
    self.class.add(@id, self)
  end

  def type
    return "knowledge"
  end

  def learn_result(character, character_action)
    return @learn_result.call(character, character_action)
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
    :description=>"", 
  }
)
Knowledge.new("craft_cutter", 
  { :name=>"Craft Cutter", 
    :description=>"", 
  }
)
Knowledge.new("craft_shaper", 
  { :name=>"Craft Shaper", 
    :description=>"", 
  }
)
