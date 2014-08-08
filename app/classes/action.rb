class Action
  extend CollectionTracker
  include Targetable
  attr_reader :id, :name, :description, :result, :cost, :available, :target_prompt, :requires_target

  def initialize(id, params={})
    @id = id
    @name = params[:name] || "Name Error"
    @description = params[:description] || "Description Error"
    @result = params[:result] || lambda { |character, character_action| return "Function error." }
    @cost = params[:cost] || lambda { |character| return 1 }
    @available = params[:available] || lambda { |character| return true }
    @requires_target = params[:requires_target] || false
    @target_prompt = params[:target_prompt] || "Targeting Prompt error"
    @valid_targets = params[:valid_targets] || {}
    self.class.add(@id, self)
  end

  def available?(character)
    return @available.call(character)
  end
end

# Format for new actions
# 'id', {:name => 'Name', :description=>"Multi-word description.", 
# :result => lambda {|character, character_action| return "Some string based on what happens, possibly conditional on character state" }, // Takes a character, returns a string
# :cost => lambda {|character| if(character.loves_chicken) return 5; else return 6;} // Takes a character, returns a digit
# :available => lambda {|character| return true or false} // Whether or not the player can currently do this action
# :valid_targets => {'type_name' => ['id', 'id']} // Types are possessions, knowledges, ideas, conditions, characters. 'all' can be used in place of an id to indicate that every object of that type is a valid target. Knowledges are specifically known knowledges, and ideas are considered knowledges.
# }

Action.new("forage",
  { :name=>"Forage", 
    :description=>"You rummage through the underbrush.", 
    :result => lambda { |character, character_action|
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
    :result => lambda { |character, character_action| 
      return character.world.explore_with(character)
    },
    :cost => lambda { |character| return 5 },
  }
)
Action.new("ponder",
  { :name=>"Ponder",
    :description=>"You think for a while.",
    :result => lambda { |character, character_action|
      target_type = character_action.target_type
      target = character_action.target.get
      if( (target_type == 'possession' && target.id == 'food') ||
          (target_type == 'possession' && target.id == 'wildlands') ||
          (target_type == 'condition' && target.id == 'hunger') )
        if(character.knows?("basic_farming") || character.considers?("basic_farming"))
          return "You ponder the #{target.name}, but nothing new comes to mind."
        else
          character.consider('basic_farming')
          return "You ponder the #{target.name}. You wonder if you could grow your own food, given the opportunity."
        end
      else
        return "You ponder the #{target.name}, but it reveals nothing about life's ineffable mysteries."
      end
    },
    :cost => lambda { |character| return 3 },
    :available => lambda { |character|
      return character.knows?("cognition")
    },
    :requires_target => true,
    :valid_targets => {"possession"=>['all'], "condition"=>['all'], "knowledge"=>['all'], "character"=>['all']},
    :target_prompt => "What would you like to ponder?",
  }
)
Action.new("investigate",
  { :name=>"Investigate",
    :description=>"Pursue a promising idea.",
    :result => lambda { |character, character_action|
      target_type = character_action.target_type
      target = character_action.target.get
      if(target_type == 'idea')
        if(target.id == 'basic_farming')
          if(character.knows?("basic_farming"))
            return "You consider your ideas for #{target.name} more fully, but don't think further investigation will accomplish anything here."
          else
            character.learn('basic_farming')
            return "Eureka! You discover the secrets of #{target.name}!"
          end
        end
      else
        return "Don't be asburd! You can't investigate #{target.name}, you can only investigate ideas!"
      end
    },
    :cost => lambda { |character| return 3 },
    :available => lambda { |character|
      return (character.knows?("cognition") && !character.ideas.empty?)
    },
    :requires_target => true,
    :valid_targets => {"idea"=>['all']},
    :target_prompt => "What would you like to investigate?",
  }
)
Action.new("clear_land",
  { :name=>"Clear Land",
    :description=>"Turn a plot of wilderness into a plot of farmable field.",
    :result => lambda { |character, character_action|
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
    :description=>"You plant your seeds.",
    :result => lambda { |character, character_action|
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
    :description=>"You harvest the crops.",
    :result => lambda { |character, character_action|
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
