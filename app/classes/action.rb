class Action
  extend CollectionTracker
  attr_reader :id, :name, :description, :result, :cost, :available, :target_prompt

  def initialize(id, params={})
    @id = id
    @name = params[:name] || "Name Error"
    @description = params[:description] || "Description Error"
    @result = params[:result] || lambda { |character| return "Function error." }
    @cost = params[:cost] || lambda { |character| return 1 }
    @available = params[:available] || lambda { |character| return true }
    @target_prompt = params[:target_prompt] || "Targeting Prompt error"
    @targets = params[:valid_targets] || {}
    self.class.add(@id, self)
  end

  def targetable(type, id)
    if(self.valid_targets[type] && (self.valid_target[type].include?(id) || self.valid_target[type].include?('all')))
      return true
    else
      return false
    end
  end

  # Takes a character, and returns a list of valid targets, sorted by type, that character can select for this action
  def valid_targets(character)
    valid = {}
    @targets.each do |target_type, values|
      target_objects = []
      if(target_type == 'possession')
        if(values.include?('all'))
          target_objects = character.character_possessions
        else
          character.character_possessions.each do |character_possession|
            if(values.include?(character_possession.possession_id))
              target_objects << character_possession
            end
          end
        end
      elsif(target_type == 'knowledge')
        if(values.include?('all'))
          # Only pull from knowledges ACTUALLY known, not just those considered. You cannot consider an idea.
          target_objects = character.knowledges
        else
          character.knowledges.each do |character_knowledge|
            if(values.include?(character_knowledge.knowledge_id))
              target_objects << character_knowledge
            end
          end
        end
      elsif(target_type == 'character')
        if(values.include?('all'))
          target_objects = character.world.characters
        end
      elsif(target_type == 'condition')
        if(values.include?('all'))
          target_objects = character.character_conditions
        else
          character.character_conditions.each do |character_conditions|
            if(values.include?(character_condition.condition_id))
              target_objects << character_condition
            end
          end
        end
      else
        raise "Invalid target type for Action: valid targets"
      end
      valid[target_type]=target_objects
    end
  end
end

# Format for new actions
# 'id', {:name => 'Name', :description=>"Multi-word description.", 
# :result => lambda {|character| return "Some string based on what happens, possibly conditional on character state" }, // Takes a character, returns a string
# :cost => lambda {|character| if(character.loves_chicken) return 5; else return 6;} // Takes a character, returns a digit
# :available => lambda {|character| return true or false} // Whether or not the player can currently do this action
# :valid_targets => {'type_name' => ['id', 'id']} // Types are possession, knowledge, condition, character. 'all' can be used in place of an id to indicate that every object of that type is a valid target
# }

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
    },
    :valid_targets => {'possession'=>['all'], 'condition'=>['all'], 'knowledge'=>['all'], 'character'=>['all']},
    :target_prompt => "What would you like to ponder?",
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
      if(character.possesses?("field") && character.possesses?("seed"))
        seed = character.character_possessions.where(:possession_id => "seed").first
        character.character_possessions.where(:possession_id => "field").first.destroy!
        CharacterPossession.new(:character_id => character.id, :possession_id => "farm", :variant => seed.variant).save!
        seed_name = Plant.find(seed.variant).seed_name
        seed.destroy!
        return "You plow a field and plant your #{seed_name}."
      else
        if(!character.possesses?("field"))
          return "You have no field to sow."
        elsif(!character.possesses?("seed"))
          return "You have no seeds to sow in the field"
        else
          return "We don't know why sowing the field didn't work, but it didn't."
        end
      end
    },
    :cost => lambda { |character| return 5 },
    :available => lambda { |character|
      return character.knows?("basic_farming") && character.possesses?("field") && character.possesses?("seed")
    }
  }
)
Action.new("harvest",
  { :name=>"Harvest Fields",
    :description=>"You think for a while.",
    :result => lambda { |character|
      if(character.possesses?("farm"))
        farm = character.character_possessions.where(:possession_id=>"farm").first
        5.times do
          CharacterPossession.new(:character_id => character.id, :possession_id => "food", :variant => farm.variant).save!
        end
        CharacterPossession.new(:character_id => character.id, :possession_id => "field").save!
        food_name = Plant.find(farm.variant).food_name
        farm.destroy!
        return "You harvest a field of #{food_name}, gaining 5 food."
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
