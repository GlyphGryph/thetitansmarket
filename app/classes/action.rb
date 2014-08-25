class Action
  extend CollectionTracker
  include Targetable
  attr_reader :id, :name, :description, :target_prompt

  def initialize(id, params={})
    @id = id
    @name = params[:name] || "Name Error"
    @description = params[:description] || "Description Error"

    @base_success_chance = params[:base_success_chance] || 100
    @success_modifiers = params[:success_modifiers] || {}

    @consumes = params[:consumes] || []
    @requires = params[:requires] || {}
    @result = params[:result] || lambda { |character, action| return "Function error." }
    @messages = params[:messages] || {}

    @valid_targets = @requires[:target] || {}
    @target_prompt = params[:target_prompt] || "Targeting Prompt error"

    @base_cost = params[:base_cost] || lambda { |character, target=nil| return 0 } 
    @cost_modifiers = params[:cost_modifiers] || {}

    self.class.add(@id, self)
  end

  def available?(character)
    available = true
    if(@requires)
      if(@requires[:possession])
        @requires[:possession].each do |required|
          available = available && character.possesses?(required[:id], required[:quantity])
        end
      end
      if(@requires[:knowledge])
        @requires[:knowledge].each do |required|
          available = available && character.knows?(required)
        end
      end
      if(@requires[:custom])
        @requires[:custom].each do |required|
          available = available && required.call(character)
        end
      end
      if(@requires[:target])
        # Character must have at least one of the valid targets
        found = false
        # If characters are a valid target, this is always true
        if(@valid_targets.keys.include?('character'))
          found = true
        else
          @valid_targets.each do |type, values|
            # If it's one of the others, find a match
            if(type==:possession)
              if(values.include?('all'))
                found = found || character.character_possessions.length > 0
              else
                values.each do |possibility|
                  found = found || character.possesses?(possibility)
                end
              end
            elsif(type==:idea)
              if(values.include?('all'))
                found = found || character.ideas.length > 0
              else
                values.each do |possibility|
                  found = found || character.considers?(possibility)
                end
              end
            elsif(type==:knowledge)
              if(values.include?('all'))
                found = found || character.knowledges.length > 0
              else
                values.each do |possibility|
                  found = found || character.knows?(possibility)
                end
              end
            elsif(type==:condition)
              if(values.include?('all'))
                found = found || character.character_conditions.length > 0
              else
                values.each do |possibility|
                  found = found || character.has_condition?(possibility)
                end
              end
            end
            if(found)
              break
            end
          end
        end
        available = available && found
      end
    end
    if(@consumes)
      @consumes.each do |required|
        # Consumed targets must have full specifications in the requires hash
        if(required != :target)
          available = available && character.possesses?(required[:id], required[:quantity])
        end
      end
    end
    return available
  end

  def executable?(character, character_action)
    available = self.available?(character)
    if(@requires)
      if(@requires[:target])
        if(character_action.target && character_action.target.get)
          valid_target_types = @requires[:target].keys
          found = false
          valid_target_types.each do |type|
            target_ids = @requires[:target][type]
            found = found || target_ids.include?('all') || target_ids.include?(character_action.target.get.id)
          end
          available = available && character_action.target.get.id
        else
          available = false
        end
      end
    end
  end

  def unmodified_cost(character, target_type = nil, target_id = nil)
    cost = 0
    cost = @base_cost.call(character)
    return cost
  end
    
  def cost(character, target_type = nil, target_id = nil)
    cost = self.unmodified_cost(character, target_type, target_id)
    # Note: If an action costs at least 1ap, the modifier should not be able to reduce the cost below zero
    # If an action is already free, it cannot be reduced at all (although it can be increased)
    modifier = 0.0
    if(@cost_modifiers[:damage])
      modifier += @cost_modifiers[:damage].to_f * character.damage_fraction
    end
    if(@cost_modifiers[:despair])
      modifier += @cost_modifiers[:despair].to_f * character.despair_fraction
    end
    if(@cost_modifiers[:possession])
      @cost_modifiers[:possession].each do |possession|
        if character.possesses?(possession[:id])
          modifier += possession[:modifier]
        end
      end
    end
    modifier = modifier.round

    cost += modifier
  end

  def result(character, character_action)
    if(!self.executable?(character, character_action))
      if(character_action)
        outcome = ActionOutcome.new(:impossible)
      else
        outcome = ActionOutcome.new(:impossible, character_action.target.get.name)
      end
    else
      success_chance = self.success_chance(character)
      if(Random.new.rand(1..100) > success_chance)
        if(character_action)
          outcome = ActionOutcome.new(:failure)
        else
          outcome = ActionOutcome.new(:failure, character_action.target.get.name)
        end
      else
        outcome = @result.call(character, character_action)
      end
      @consumes.each do |consumed|
        if(consumed==:target)
          character_action.target.destroy!
        else
          consumed[:quantity].times do
            character.character_possessions.where(:possession_id=>consumed[:id]).first.destroy!
          end
        end
      end
    end
    success = (outcome.status != :failure)
    message = @messages[outcome.status] || lambda {|args| "Error: Message not provided for this outcome."}
    message = message.call(outcome.arguments)
    if(success_chance < 100)
      message += " (#{ success ? "Success" : "Failure"}: #{success_chance}% chance of success)"
    end
    return ActionResult.new(success, message, self.id)
  end
  
  def requires_target?
    return !!@requires[:target]
  end

  def success_chance(character)
    chance = @base_success_chance
    if(@success_modifiers[:possession])
      @success_modifiers[:possession].each do |possession|
        if character.possesses?(possession[:id])
          chance += possession[:modifier]
        end
      end
    end
    return chance
  end

  def type
    return "action"
  end
end

class ActionResult
  attr_accessor :success, :cost, :message, :type

  def initialize(success=true, message="Error: No Message Provided", type="untyped")
    @success = success
    @message = message
    @type = type
  end
end

class ActionOutcome
  attr_accessor :status, :arguments
  def initialize(status, *arguments)
    @status = status
    @arguments = arguments
  end
end

# Format for new actions
# 'id', {:name => 'Name', 
# :description => "Multi-word description.", 
# :base_success_chance => % number
# :success_modifiers => {
#   :possession => { :item_id => modifier number, :item_id => modifier number }
#   :knowledge => { :knowledge_id => modifier number, :knowledge_id => modifier number }
#   :condition => { :condition_id => modifier number, :condition_id => modifier number }
#   :trait => { :condition_id => modifier number, :condition_id => modifier number }
# }
# :result => lambda {|character, character_action| return "Some string based on what happens, possibly conditional on character state" }, // Takes a character, returns a string
# :base_cost  => lambda { |character, target| return cost }
# :consumes => [ [:item_id, #], [:item_id, #] ]
# :requires => {
#   :possession => [ [:item_id => amount], [:item_id => amount] ]
#   :knowledge => [ :knowledge_id, :knowledge_id ]
#   :condition => [ :condition_id, :condition_id ]
#   :trait => [ :trait_id, :trait_id ]
#   :target => true/false
# }
# :available => lambda {|character| return true or false} // Whether or not the player can currently do this action
# :physical_cost_penalty => The maximum amount of ap cost increase for injury
# :mental_cost_penalty => The maximum amount of ap cost increase for sadness
# :valid_targets => {'type_name' => ['id', 'id']} // Types are possessions, knowledges, ideas, conditions, characters. 'all' can be used in place of an id to indicate that every object of that type is a valid target. Knowledges are specifically known knowledges, and ideas are considered knowledges.
# }

#################
# Basic Actions #
#################
Action.new("forage",
  { :name => "Forage", 
    :description => "You rummage through the underbrush.", 
    :base_success_chance => 50,
    :result => lambda { |character, character_action|
      found = Plant.all.sample
      if(character.possesses?("basket"))
        amount_found = Random.new.rand(3)+1
        amount_found.times do
          CharacterPossession.new(:character_id => character.id, :possession_id => "food", :variant=>found.id).save!
        end
        amount_found_string = (amount_found > 1) ? "#{amount_found} meals" : "#{amount_found} meal"
        return ActionOutcome.new(:basket_success, found.plant_name, found.food_name, amount_found_string)
      else
        CharacterPossession.new(:character_id => character.id, :possession_id => "food", :variant=>found.id).save!
        return ActionOutcome.new(:success, found.plant_name, found.food_name)
      end
    },
    :messages => {
      :basket_success => lambda { |args| "You forage through the underbrush and discover a #{args[0]}. You gather enough #{args[1]} into your basket for #{args[2]}. Food!" },
      :success => lambda { |args| "You forage through the underbrush and discover a #{args[0]}. You gather some #{args[1]}. Food!" },
      :failure => lambda { |args| "You forage through the underbrush, but find only disappointment." },
      :impossible => lambda { |args| "You could not forage." },
    },
    :base_cost => lambda { |character, target=nil| return 2 },
    :cost_modifiers => {
      :damage => 2,
      :despair => 2,
    },
  }
)


##########################
# Discovery and Research #
##########################
Action.new("explore", 
  { :name => "Explore", 
    :description => "You explore the wilds.", 
    :base_success_chance => 100,
    :result => lambda { |character, character_action| 
      return ActionOutcome.new(:success, character.world.explore_with(character))
    },
    :messages => {
      :success => lambda { |args| args[0] },
      :impossible => lambda { |args| "You could not explore." },
    },
    :base_cost => lambda { |character, target=nil| return 5 },
    :cost_modifiers => {
      :damage => 5,
      :despair => 5,
    },
  }
)

Action.new("ponder",
  { :name => "Ponder",
    :description => "You think for a while.",
    :base_success_chance => 100,
    :result => lambda { |character, character_action|
      target = character_action.target.get
      found = false
      succeeded = false
      text = ["You ponder the #{target.name}."]
      Thought.all.each do |thought|
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
        text = text.join(" ")
        return ActionOutcome.new(:failure, text)
      elsif(!succeeded)
        text = text.join(" ")
        return ActionOutcome.new(:already_pondered, text)
      end

      text = text.join(" ")
      return ActionOutcome.new(:success, text)
    },
    :messages => {
      :success => lambda { |args| args[0] },
      :already_pondered => lambda { |args| "#{args[0]} Nothing new comes to mind." },
      :failure => lambda { |args| "#{args[0] || "You ponder the unknown object."} It reveals nothing about life's inscrutable mysteries." },
      :impossible => lambda { |args| "You could not think." },
    },
    :requires => {
      :knowledge => ['cognition'],
      :target => {:possession=>['all'], :condition=>['all'], :knowledge=>['all'], :character=>['all']},
    },
    :target_prompt => "What would you like to ponder?",
    :base_cost => lambda { |character, target=nil| return 3 },
    :cost_modifiers => {
      :despair => 5,
    },
  }
)
Action.new("investigate",
  { :name => "Investigate",
    :description => "Pursue a promising idea.",
    :base_success_chance => 100,
    :result => lambda { |character, character_action|
      target_type = character_action.target_type
      target = character_action.target.get

      if(target_type == 'idea' && Thought.find(target.id) && Knowledge.find(target.id))
        if(character.knows?(target.id))
          return ActionOutcome.new(:already_investigated, target.name)
        else
          character.learn(target.id)
          thought_research = Thought.find(target.id).research
          succeeded = true
        end
      else
        return ActionOutcome.new(:impossible, target.name)
      end

      return ActionOutcome.new(:success, target.name, thought_research)
    },
    :messages => {
      :success => lambda { |args| "You dig deeper into the possibilities of #{args[0]}. #{args[1]}" },
      :already_investigated => lambda { |args| "You consider your ideas for #{args[0]} more fully, but don't think further investigation will accomplish anything here." },
      :failure => lambda { |args| "You fail to learn anything about #{args[0]}." },
      :impossible => lambda { |args| "Don't be absurd! You can't investigate #{args[0]}, you can only investigate ideas!" },
    },
    :requires => {
      :knowledge => ['cognition'],
      :target => {:idea=>['all']},
      :custom => [ lambda { |character| !character.ideas.empty? } ]
    },
    :target_prompt => "What would you like to investigate?",
    :base_cost => lambda { |character, target=nil| return 3 },
    :cost_modifiers => {
      :damage => 4,
      :despair => 4,
    },
  }
)

###########
# Farming #
###########
Action.new("clear_land",
  { :name => "Clear Land",
    :description => "Turn a plot of wilderness or a grove into a plot of farmable field.",
    :base_success => 100,
    :result => lambda { |character, character_action|
      target = character_action.target.get
      CharacterPossession.new(:character_id => character.id, :possession_id => "field").save!
      if(target.id == 'dolait')
        15.times do
          CharacterPossession.new(:character_id => character.id, :possession_id => "dolait").save!
        end
      elsif(target.id == 'wildlands')
        Random.new.rand(1..4).times do
          found = Plant.all.sample
          CharacterPossession.new(:character_id => character.id, :possession_id => "food", :variant => found.id).save!
        end
      end
      return ActionOutcome.new(:success, target.name)
      return "You clear a field."
    },
    :messages => {
      :success => lambda { |args| "You clear your #{args[0]} and turn it into a field." },
      :failure => lambda { |args| "You fail to clear the land." },
      :impossible => lambda { |args| "You couldn't clear the land." },
    },
    :consumes => [:target],
    :requires => {
      :knowledge => ['basic_farming'],
      :target => {:possession=>['wildlands', 'dolait_source']},
    },
    :target_prompt => "What would you like to clear?",
    :base_cost => lambda { |character, target=nil| return 8 },
    :cost_modifiers => {
      :damage => 10,
      :despair => 2,
    },
  }
)

Action.new("plant",
  { :name => "Sow Fields",
    :description => "You plant your seeds.",
    :base_success => 100,
    :result => lambda { |character, character_action|
      seed = character_action.target
      CharacterPossession.new(:character_id => character.id, :possession_id => "farm", :variant => seed.variant).save!
      return ActionOutcome.new(:success, seed.get.name)
    },
    :messages => {
      :success => lambda { |args| "You plow a field and plant your #{args[0]}." },
      :failure => lambda { |args| "You failed to sow the field." },
      :impossible => lambda { |args| "You could not sow the field." },
    },
    :consumes => [
      {:id => 'field', :quantity => 1}, 
      :target,
    ],
    :requires => {
      :knowledge => ['basic_farming'],
      :target => {:possession=>['seed']},
    },
    :target_prompt => "What would you like to plant?",
    :base_cost => lambda { |character, target=nil| return 5 },
    :cost_modifiers => {
      :damage => 3,
      :despair => 1,
    },
  }
)
# Action.new("harvest_fields",
#   { :name => "Harvest Fields",
#     :description => "You harvest the crops.",
#     :result => lambda { |character, character_action|
#       if(character.possesses?("farm"))
#         farm = character.character_possessions.where(:possession_id => "farm").first
#         5.times do
#           CharacterPossession.new(:character_id => character.id, :possession_id => "food", :variant => farm.variant).save!
#         end
#         CharacterPossession.new(:character_id => character.id, :possession_id => "field").save!
#         food_name = Plant.find(farm.variant).food_name
#         farm.destroy!
#         return "You harvest a field of #{food_name}, gaining 5 food."
#       else
#         return "You attempted to harvest a field, but it failed."
#       end
#     },
#     :base_cost => lambda { |character, target=nil| return 5 },
#     :available => lambda { |character|
#       return character.knows?("basic_farming") && character.possesses?("farm")
#     },
#     :physical_cost_penalty => 4,
#     :mental_cost_penalty => 1,
#   }
# )
# 

##############
# Scavenging #
##############
Action.new("harvest_dolait",
  { :name => "Harvest Dolait",
    :description => "You harvest some dolait from the grove.",
    :base_success_chance => 75,
    :success_modifiers => {
      :possession => [
        {:id => 'cutter', :modifier => 25},
      ],
    },
    :result => lambda { |character, character_action|
      CharacterPossession.new(:character_id => character.id, :possession_id => "dolait").save!
      if(character.possesses?("dolait_source"))
        return ActionOutcome.new(:success_cutter)
      else
        return ActionOutcome.new(:success)
      end
    },
    :messages => {
      :success_cutter => lambda { |args| "You use your cutter to harvest some fresh dolait." },
      :success => lambda { |args| "You break off some fresh dolait branches." },
      :failure => lambda { |args| "The dolait you find proves too tough to gather." },
      :impossible => lambda { |args| "You couldn't gather dolait." },
    },
    :requires => {
      :possession => [{:id => 'dolait_source', :quantity => 1},],
      :knowledge => ['basic_dolait'],
    },
    :base_cost => lambda { |character, target=nil| return 5 },
    :cost_modifiers => {
      :damage => 4,
      :despair => 1,
    },
  }
)
Action.new("gather_tomatunk",
  { :name => "Gather Tomatunk",
    :description => "Go looking for chunks of tomatunk in the marsh.",
    :base_success_chance => 34,
    :result => lambda { |character, character_action|
      if(character.possesses?("basket"))
        amount_found = Random.new.rand(3)+1
        amount_found.times do
          CharacterPossession.new(:character_id => character.id, :possession_id => "tomatunk").save!
        end
        if(amount_found > 1)
          return ActionOutcome.new(:basket_success, "#{amount_found.to_s} blocks")
        else
          return ActionOutcome.new(:basket_success, "1 block")
        end
      else
        CharacterPossession.new(:character_id => character.id, :possession_id => "tomatunk").save!
        return ActionOutcome.new(:success)
      end
    },
    :messages => {
      :basket_success => lambda { |args| "You wade until you find some tomatunk. You gather #{args[0]} of tomatunk into your basket." },
      :success => lambda { |args| "You wade through the mud and find a hefty block of tomatunk!" },
      :failure => lambda { |args| "You get soggy and dirty looking for tomatunk, but find only disappointment." },
      :impossible => lambda { |args| "You couldn't gather tomatunk." },
    },
    :requires => {
      :possession => [{:id => 'tomatunk_source', :quantity => 1},],
      :knowledge => [:basic_tomatunk],
    },
    :base_cost => lambda { |character, target=nil| return 3 },
    :cost_modifiers => {
      :damage => 3,
      :despair => 3,
    },
  }
)
Action.new("gather_wampoon",
  { :name => "Gather Wampoon",
    :description => "Go looking for wampoon in the barrens.",
    :base_success_chance => 25,
    :result => lambda { |character, character_action|
      CharacterPossession.new(:character_id => character.id, :possession_id => "wampoon").save!
      return ActionOutcome.new(:success)
    },
    :messages => {
      :success => lambda { |args| "After hours of searching, you find some scraps of wampoon under a rock." },
      :failure => lambda { |args| "The barrens are as empty as they appear - you don't find a single shard of wampoon." },
      :impossible => lambda { |args| "You couldn't gather wampoon." },
    },
    :requires => {
      :possession => [{:id => "wampoon_source", :quantity=>1},],
      :knowledge => [:basic_wampoon],
    },
    :base_cost => lambda { |character, target=nil| return 3 },
    :cost_modifiers => {
      :damage => 3,
      :despair => 3,
    },
  }
)

#    :messages => {
#      :success => lambda { |args| "" },
#      :failure => lambda { |args| "" },
#      :impossible => lambda { |args| "" },
#    },
#    :consumes => [{:id => ""}],
#    :requires => {
#      :knowledge => [:],
#    },
#    :base_cost => lambda { |character, target=nil| 
#      return 7
#    },
#    :cost_modifiers => {
#      :possession => [
#        {:id => '', :modifier => 0.0},
#      ],
#      :damage => 0,
#      :despair => 0,
#    },

############
# Crafting #
############
Action.new("craft_basket",
  { :name => "Craft Basket",
    :description => "Craft a simple tool to aid in gathering.",
    :base_success_chance => 50,
    :result => lambda { |character, character_action|
      CharacterPossession.new(:character_id => character.id, :possession_id => "basket").save!
      return ActionOutcome.new(:success)
    },
    :messages => {
      :success => lambda { |args| "You weave strips of dolait into a basket, and then treat the material to harden it." },
      :failure => lambda { |args| "The dolait tears before the basket is finished, wasting both time and materials." },
      :impossible => lambda { |args| "You don't have any dolait left to make a basket with." },
    },
    :consumes => [{:id => "dolait", :quantity => 1}],
    :requires => {
      :knowledge => [:craft_basket],
    },
    :base_cost => lambda { |character, target=nil| return 7 },
    :cost_modifiers => {
      :possession => [
        {:id => 'shaper_a', :modifier => -0.7},
        {:id => 'shaper_b', :modifier => -0.7},
        {:id => 'shaper_c', :modifier => -0.7},
      ],
      :damage => 3,
      :despair => 2,
    },
  }
)
Action.new("craft_cutter",
  { :name => "Craft Cutter",
    :description => "Craft a simple cutting tool to aid in harvesting.",
    :base_success_chance => 50,
    :result => lambda { |character, character_action|
      CharacterPossession.new(:character_id => character.id, :possession_id => "cutter").save!
      return ActionOutcome.new(:success)
    },
    :messages => {
      :success => lambda { |args| "You craft a simple cutter." },
      :failure => lambda { |args| "You crack the cutter - it's useless, and the tomatunk has been wasted." },
      :impossible => lambda { |args| "You don't have the materials to craft a cutter." },
    },
    :consumes => [{:id => "tomatunk", :quantity => 1}],
    :requires => {
      :knowledge => [:craft_cutter],
    },
    :base_cost => lambda { |character, target=nil| return 7 },
    :cost_modifiers => {
      :possession => [
        {:id => 'shaper_a', :modifier => -0.7},
        {:id => 'shaper_b', :modifier => -0.7},
        {:id => 'shaper_c', :modifier => -0.7},
      ],
      :damage => 3,
      :despair => 2,
    },
  }
)

Action.new("craft_shaper_a",
  { :name => "Craft Oblong Shaper",
    :description => "Craft a simple oblong shaping tool to aid in crafting.",
    :base_success_chance => 50, 
    :result => lambda { |character, character_action|
      CharacterPossession.new(:character_id => character.id, :possession_id => "shaper_b").save!
      return ActionOutcome.new(:success)
    },
    :messages => {
      :success => lambda { |args| "You craft an oblong shaper." },
      :failure => lambda { |args| "Your oblong shaper breaks most of the way through the process. It's ruined." },
      :impossible => lambda { |args| "You don't have the materials to craft a shaper." },
    },
    :consumes => [{:id => "dolait", :quantity => 1},{:id => "tomatunk", :quantity => 1}],
    :requires => {
      :knowledge => [:craft_shaper],
    },
    :base_cost => lambda { |character, target=nil| return 7 },
    :cost_modifiers => {
      :possession => [
        {:id => 'shaper_a', :modifier => -0.7},
        {:id => 'shaper_b', :modifier => -0.7},
        {:id => 'shaper_c', :modifier => -0.7},
      ],
      :damage => 3,
      :despair => 2,
    },
  }
)
Action.new("craft_shaper_b",
  { :name => "Craft Angled Shaper",
    :description => "Craft a simple angled shaping tool to aid in crafting.",
    :base_success_chance => 50, 
    :result => lambda { |character, character_action|
      CharacterPossession.new(:character_id => character.id, :possession_id => "shaper_b").save!
      return ActionOutcome.new(:success)
    },
    :messages => {
      :success => lambda { |args| "You craft an angled shaper." },
      :failure => lambda { |args| "Your angled shaper breaks most of the way through the process. It's ruined." },
      :impossible => lambda { |args| "You don't have the materials to craft a shaper." },
    },
    :consumes => [{:id => "dolait", :quantity => 1},{:id => "tomatunk", :quantity => 1}],
    :requires => {
      :knowledge => [:craft_shaper],
    },
    :base_cost => lambda { |character, target=nil| return 7 },
    :cost_modifiers => {
      :possession => [
        {:id => 'shaper_a', :modifier => -0.7},
        {:id => 'shaper_b', :modifier => -0.7},
        {:id => 'shaper_c', :modifier => -0.7},
      ],
      :damage => 3,
      :despair => 2,
    },
  }
)
Action.new("craft_shaper_c",
  { :name => "Craft Pronged Shaper",
    :description => "Craft a simple pronged shaping tool to aid in crafting.",
    :base_success_chance => 50, 
    :result => lambda { |character, character_action|
      CharacterPossession.new(:character_id => character.id, :possession_id => "shaper_c").save!
      return ActionOutcome.new(:success)
    },
    :messages => {
      :success => lambda { |args| "You craft a pronged shaper." },
      :failure => lambda { |args| "Your pronged shaper breaks most of the way through the process. It's ruined." },
      :impossible => lambda { |args| "You don't have the materials to craft a shaper." },
    },
    :consumes => [{:id => "dolait", :quantity => 1},{:id => "tomatunk", :quantity => 1}],
    :requires => {
      :knowledge => [:craft_shaper],
    },
    :base_cost => lambda { |character, target=nil| return 7 },
    :cost_modifiers => {
      :possession => [
        {:id => 'shaper_a', :modifier => -0.7},
        {:id => 'shaper_b', :modifier => -0.7},
        {:id => 'shaper_c', :modifier => -0.7},
      ],
      :damage => 3,
      :despair => 2,
    },
  }
)
