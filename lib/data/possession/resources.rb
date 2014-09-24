Possession.new("food", 
  { :name => "Food", 
    :description => "This thing is, more or less, edible.", 
    :max_charges  =>  2,
    :age => lambda { |character_possession|
      if(character_possession.deplete(1) && character_possession.charges > 0)
        return AgeResult.new(:silent)
      else
        character = character_possession.character
        message = "Your #{character_possession.possession_variant.singular_name} has rotted away."
        CharacterPossession.new(:character => character, :possession_id => "rot").save!
        # If this has seeds and the character knows to save them, create them as well
        if(character.knows?("basic_farming"))
          CharacterPossession.new(:character => character, :possession_id => 'seed', :variant=>food.variant).save!
        end
        character_possession.destroy!
        return AgeResult.new(:loud, message)
      end
    },
  }
)
Possession.new("seed", 
  { :name => "Seeds", 
    :description => "These seeds can be planted.", 
  }
)
Possession.new("dolait",
  { :name => "Dolait Chunk",
    :description => "This is a chunk of harvested dolait.",
  }
)
Possession.new("tomatunk",
  { :name => "Tomatunk Block",
    :description => "This is a block of gathered tomatunk.",
  }
)
Possession.new("wampoon",
  { :name => "Wampoon Shard",
    :description => "This is a shard of gathered wampoon.",
  }
)
Possession.new("rot",
  { :name => "Rot",
    :description => "Some kind of rotted organic matter. It could have been anything, and whatever it is wont last much longer.",
    :max_charges  =>  2,
    :age => lambda { |character_possession|
      if(character_possession.deplete(1) && character_possession.charges > 0)
        return AgeResult.new(:silent)
      else
        message = "A pile of rotted biomass has finished decaying."
        character_possession.destroy!
        return AgeResult.new(:loud, message)
      end 
    },
  }
)
