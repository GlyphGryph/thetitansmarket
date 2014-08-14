class Action
  extend CollectionTracker
  include Targetable
  attr_reader :id, :name, :description, :available, :target_prompt

  def initialize(id, params={})
    @id = id
    @name = params[:name] || "Name Error"
    @description = params[:description] || "Description Error"
    @result = params[:result] || lambda { |character, action| return "Function error." }
    @base_cost = params[:base_cost] || 0
    @targeted_cost = params[:targeted_cost] || lambda { |character, target| return 0 }
    @cost_requires_target = params[:cost_requires_target]
    @available = params[:available] || lambda { |character| return true }
    @requires_target = params[:requires_target] || false
    @target_prompt = params[:target_prompt] || "Targeting Prompt error"
    @valid_targets = params[:valid_targets] || {}
    @physical_cost_penalty = params[:physical_cost_penalty] || 0
    @mental_cost_penalty = params[:mental_cost_penalty] || 0
    self.class.add(@id, self)
  end

  def available?(character)
    return @available.call(character)
  end

  def unmodified_cost(character, target_type = nil, target_id = nil)
    cost = 0
    if(self.cost_requires_target?)
      if(target_type && target_id)
        cost = @targeted_cost.call(character, target_type, target_id)
      else
        raise "Calculating the cost for #{self.name} requires a target."
      end
    else
      cost = @base_cost
    end
    return cost
  end
    
  def cost(character, target_type = nil, target_id = nil)
    cost = self.unmodified_cost(character, target_type, target_id)
    # Note: If an action costs at least 1ap, the modifier should not be able to reduce the cost below zero
    # If an action is already free, it cannot be reduced at all (although it can be increased)
    modifier = 0
    modifier += @physical_cost_penalty.to_f * character.fraction_hp_missing
    modifier += @mental_cost_penalty.to_f * character.fraction_happy_missing
    modifier = modifier.round

    cost += modifier
  end

  def cost_requires_target?
    return @cost_requires_target
  end

  def result(character, target)
    return @result.call(character, target)
  end
  
  def requires_target?
    return @requires_target
  end

  def type
    return "action"
  end
end

# Format for new actions
# 'id', {:name => 'Name', :description=>"Multi-word description.", 
# :result => lambda {|character, character_action| return "Some string based on what happens, possibly conditional on character state" }, // Takes a character, returns a string
# :base_cost  => base ap cost
# :available => lambda {|character| return true or false} // Whether or not the player can currently do this action
# :physical_cost_penalty => The maximum amount of ap cost increase for injury
# :mental_cost_penalty => The maximum amount of ap cost increase for sadness
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
    :base_cost => 2,
    :physical_cost_penalty => 2,
    :mental_cost_penalty => 2,
  }
)
Action.new("explore", 
  { :name=>"Explore", 
    :description=>"You explore the wilds.", 
    :result => lambda { |character, character_action| 
      return character.world.explore_with(character)
    },
    :base_cost => 5,
    :physical_cost_penalty => 5,
    :mental_cost_penalty => 5,
  }
)
Action.new("ponder",
  { :name=>"Ponder",
    :description=>"You think for a while.",
    :result => lambda { |character, character_action|
      target = character_action.target.get
      found = false
      succeeded = false
      text = ["You ponder the #{target.name}."]
      Thought.all.each do |thought|
        p "Checking thought #{thought.inspect} for #{target.id}"
        if(thought.sources[target.type] && thought.sources[target.type].include?(target.id))
          found = true
          if(!character.knows?(thought.id) && !character.considers?(thought.id))
            character.consider(thought.id)
            succeeded = true
            text << thought.consider
          end
        end
      end
      if(!found)
        text << "It reveals nothing about life's ineffable mysteries."
      elsif(!succeeded)
        text << "Nothing new comes to mind."
      end

      text = text.join(" ")
      return text
    },
    :base_cost => 3,
    :available => lambda { |character|
      return character.knows?("cognition")
    },
    :requires_target => true,
    :valid_targets => {"possession"=>['all'], "condition"=>['all'], "knowledge"=>['all'], "character"=>['all']},
    :target_prompt => "What would you like to ponder?",
    :mental_cost_penalty => 5,
  }
)
Action.new("investigate",
  { :name=>"Investigate",
    :description=>"Pursue a promising idea.",
    :result => lambda { |character, character_action|
      target_type = character_action.target_type
      target = character_action.target.get
      text = ["You dig deeper into the possibilities of #{target.name}."]

      if(target_type == 'idea' && Thought.find(target.id) && Knowledge.find(target.id))
        if(character.knows?(target.id))
          return "You consider your ideas for #{target.name} more fully, but don't think further investigation will accomplish anything here."
        else
          character.learn(target.id)
          text << Thought.find(target.id).research
          succeeded = true
        end
      else
        text << "Don't be asburd! You can't investigate #{target.name}, you can only investigate ideas!"
      end

      text = text.join(" ")
      return text
    },
    :base_cost => 3,
    :available => lambda { |character|
      return (character.knows?("cognition") && !character.ideas.empty?)
    },
    :requires_target => true,
    :valid_targets => {"idea"=>['all']},
    :target_prompt => "What would you like to investigate?",
    :mental_cost_penalty => 4,
    :physical_cost_penalty => 4
  }
)
Action.new("clear_land",
  { :name=>"Clear Land",
    :description=>"Turn a plot of wilderness or a grove into a plot of farmable field.",
    :result => lambda { |character, character_action|
      character_possession = character_action.target
      ActiveRecord::Base.transaction do
        character_possession.destroy!
        CharacterPossession.new(:character_id => character.id, :possession_id => "field").save!
      end
      return "You clear a field."
    },
    :base_cost => 8,
    :available => lambda { |character|
      return character.knows?("basic_farming") && character.possesses?("wildlands")
    },
    :requires_target => true,
    :valid_targets => {"possession"=>['wildlands', 'dolait']},
    :target_prompt => "What would you like to clear?",
    :physical_cost_penalty => 30,
    :mental_cost_penalty => 2
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
    :base_cost => 5,
    :available => lambda { |character|
      return character.knows?("basic_farming") && character.possesses?("field") && character.possesses?("seed")
    },
    :physical_cost_penalty => 3,
    :mental_cost_penalty => 1,
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
    :base_cost => 5,
    :available => lambda { |character|
      return character.knows?("basic_farming") && character.possesses?("farm")
    },
    :physical_cost_penalty => 4,
    :mental_cost_penalty => 1,
  }
)
Action.new("harvest",
  { :name=>"Harvest Dolait",
    :description=>"You harvest some dolat from the grove.",
    :result => lambda { |character, character_action|
      if(character.possesses?("dolait_source"))
        CharacterPossession.new(:character_id => character.id, :possession_id => "food", :variant => farm.variant).save!
        return "You harvest some dolait."
      else
        return "You attempted to harvest some dolait, but it failed."
      end
    },
    :base_cost => 5,
    :available => lambda { |character|
      return character.knows?("basic_dolait") && character.possesses?("dolait_source")
    },
    :physical_cost_penalty => 4,
    :mental_cost_penalty => 1,
  }
)
