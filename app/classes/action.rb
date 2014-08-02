class Action
  extend CollectionTracker
  attr_reader :id, :name, :description, :result, :cost, :available

  def initialize(id, params={})
    @id = id
    @name = params[:name] || "Name Error"
    @description = params[:description] || "Description Error"
    @result = params[:result] || lambda { |character| return "Function error." }
    @cost = params[:cost] || lambda { |character| return 1 }
    @available = params[:available] || lambda { |character| return true }
    self.class.add(@id, self)
  end
end

# Format for new actions
# 'id', {:name => 'Name', :description=>"Multi-word description.", 
# :result => lambda {|character| return "Some string based on what happens, possibly conditional on character state" }, // Takes a character, returns a string
# :cost => lambda {|character| if(character.loves_chicken) return 5; else return 6; } // Takes a character, returns a digit

Action.new("forage",
  { :name=>"Forage", 
    :description=>"You rummage through the underbrush.", 
    :result => lambda { |character|
      if(Random.rand(2)==0)
        found = Plant.all.sample
        CharacterPossession.new(:character_id => character.id, :possession_id => "food", :variant=>found.id).save!
        return "You forage through the underbrush and discover a #{found.plant_name}. You quickly gather some #{found.food_name}. Food!" 
      else
        return "You forage through the underbrush, but find only disappointment." 
      end
    },
    :cost => lambda { |character| return 3 },
  }
)
Action.new("explore", 
  { :name=>"Explore", 
    :description=>"You explore the wilds.", 
    :result => lambda { |character| 
      return character.world.explore_with(character)
    },
    :cost => lambda { |character| return 5 },
  }
)
Action.new("ponder",
  { :name=>"Ponder",
    :description=>"You think for a while.",
    :result => lambda { |character|
      character.consider('basic_farming')
      return "You ponder life's mysteries."
    },
    :cost => lambda { |character| return 3 },
    :available => lambda { |character|
      return character.knows?("cognition") && !character.knows?("basic_farming") && !character.considers?("basic_farming")
    }
  }
)
Action.new("investigate",
  { :name=>"Investigate",
    :description=>"Pursue a promising idea.",
    :result => lambda { |character|
      character.learn('basic_farming')
      return "You discover the secrets of agriculture."
    },
    :cost => lambda { |character| return 3 },
    :available => lambda { |character|
      return character.knows?("cognition") && !character.knows?("basic_farming")
    }
  }
)
Action.new("clear_land",
  { :name=>"Clear Land",
    :description=>"Turn a plot of wilderness into a plot of farmable field.",
    :result => lambda { |character|
      if(character.possesses?("wildlands"))
        character.character_possessions.where(:possession_id=>"wildlands").first.destroy!
        CharacterPossession.new(:character_id => character.id, :possession_id => "field").save!
        return "You clear a field."
      else
        return "You attempted to clear a field, but it failed."
      end
    },
    :cost => lambda { |character| return 8 },
    :available => lambda { |character|
      return character.knows?("basic_farming") && character.possesses?("wildlands")
    }
  }
)
Action.new("plant",
  { :name=>"Sow Fields",
    :description=>"You think for a while.",
    :result => lambda { |character|
      if(character.possesses?("field"))
        character.character_possessions.where(:possession_id=>"field").first.destroy!
        CharacterPossession.new(:character_id => character.id, :possession_id => "farm").save!
        return "You plow and plant a field."
      else
        return "You attemped to sow a field, but it failed."
      end
    },
    :cost => lambda { |character| return 5 },
    :available => lambda { |character|
      return character.knows?("basic_farming") && character.possesses?("field")
    }
  }
)
Action.new("harvest",
  { :name=>"Harvest Fields",
    :description=>"You think for a while.",
    :result => lambda { |character|
      if(character.possesses?("farm"))
        character.character_possessions.where(:possession_id=>"farm").first.destroy!
        CharacterPossession.new(:character_id => character.id, :possession_id => "field").save!
        5.times do
          CharacterPossession.new(:character_id => character.id, :possession_id => "food").save!
        end
        return "You harvest a field, gaining 5 food."
      else
        return "You attempted to harvest a field, but it failed."
      end
    },
    :cost => lambda { |character| return 5 },
    :available => lambda { |character|
      return character.knows?("basic_farming") && character.possesses?("farm")
    }
  }
)
