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
Possession.new("new_farm", 
  { :name=>"Newly Planted Field",
    :variant_name => lambda{ |key| return "Newly Planted #{Plant.find(key).plant_name} Field" },
    :description=>"Neat rows of turned soil, and a few sprouts just starting to reveal themselves.", 
    :age => lambda { |character_possession|
      variant_key = character_possession.possession_variant.key
      possession_id = "growing_farm"
      CharacterPossession.new(
        :character_id => character_possession.character_id,
        :possession_id => possession_id,
        :possession_variant => PossessionVariant.find_or_do(variant_key, possession_id, Possession.find(possession_id).variant_name(variant_key)),
      ).save!
      character_possession.destroy!
      return AgeResult.new(:loud, "Your farm has turned to field, and anything left unharvested has gone to waste, whether gone rotter, eaten by animals, or blackened by frost.")
    },
  }
)
Possession.new("growing_farm", 
  { :name=>"Growing Field", 
    :variant_name => lambda{ |key| return "Growing #{Plant.find(key).plant_name} Field" },
    :description=>"A field full of young plants, not yet ready to harvest.", 
    :age => lambda { |character_possession|
      variant_key = character_possession.possession_variant.key
      possession_id = "mature_farm"
      CharacterPossession.new(
        :character_id => character_possession.character_id,
        :possession_id => possession_id,
        :possession_variant => PossessionVariant.find_or_do(variant_key, possession_id, Possession.find(possession_id).variant_name(variant_key)),
      ).save!
      character_possession.destroy!
      return AgeResult.new(:loud, "Your farm has turned to field, and anything left unharvested has gone to waste, whether gone rotter, eaten by animals, or blackened by frost.")
    },
  }
)
Possession.new("mature_farm", 
  { :name=>"Mature Field",
    :variant_name => lambda{ |key| return "Mature #{Plant.find(key).plant_name} Field" },
    :description=>"A field full of food plants, ready to be harvested.", 
    :max_charges=>10,
    :age => lambda { |character_possession|
      character_possession.destroy!
      CharacterPossession.new(:character_id => character_possession.character_id,:possession_id => "field").save!
      return AgeResult.new(:loud, "Your farm has turned to field, and anything left unharvested has gone to waste, whether gone rotter, eaten by animals, or blackened by frost.")
    },
  }
)
Possession.new("dolait_source", 
  { :name=>"Dolait Grove", 
    :description=>"A thick grove of dolait.", 
    :max_charges=>25,
    :age => lambda { |character_possession|
      charges = character_possession.charges 
      if(charges > 0)
        # Regrow approximately 10% of the current grove size
        grown = (charges/10).floor
        if(rand(1..10) <= charges%10)
          grown += 1
        end
        character_possession.charges = charges
        character_possession.save!
        return AgeResult.new(:silent)
      else
        character_possession.destroy!
        CharacterPossession.new(:character_id => character_possession.character_id,:possession_id => "field").save!
        return AgeResult.new(:loud, "One of your dolait groves has become a field.")
      end
    }
  }
)
Possession.new("tomatunk_source", 
  { :name=>"Tomatunk Deposit", 
    :description=>"A marshy area with signs of tomatunk.", 
    :max_charges=>40,
  }
)
Possession.new("wampoon_source", 
  { :name=>"Wampoon Deposit", 
    :description=>"A barren, rocky area with evidence of wampoon.", 
    :max_charges=>10,
  }
)
