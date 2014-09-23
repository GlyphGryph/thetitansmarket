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
# :result => lambda {|character, target| return "Some string based on what happens, possibly conditional on character state" }, // Takes a character, returns a string
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
# :physical_cost_penalty => The maximum amount of vigor cost increase for injury
# :mental_cost_penalty => The maximum amount of vigor cost increase for sadness
# :valid_targets => {'type_name' => ['id', 'id']} // Types are possessions, knowledges, ideas, conditions, characters. 'all' can be used in place of an id to indicate that every object of that type is a valid target. Knowledges are specifically known knowledges, and ideas are considered knowledges.
# }

#################
# Basic Actions #
#################
Action.new("forage",
  { :name => "Forage", 
    :description => "You rummage through the underbrush.", 
    :base_success_chance => 50,
    :result => lambda { |character, target|
      found = Plant.all.sample
      possession_id = "food"
      if(character.possesses?("basket"))
        amount_found = Random.new.rand(3)+1
        amount_found.times do
          CharacterPossession.new(
            :character_id => character.id, 
            :possession_id => possession_id,
            :possession_variant => PossessionVariant.find_or_do(found.id, possession_id, found.food_name)
          ).save!
        end
        amount_found_string = (amount_found > 1) ? "#{amount_found} meals" : "#{amount_found} meal"
        return ActionOutcome.new(:basket_success, found.plant_name, found.food_name, amount_found_string)
      else
        CharacterPossession.new(
          :character_id => character.id, 
          :possession_id => possession_id,
          :possession_variant => PossessionVariant.find_or_do(found.id, possession_id, found.food_name)
        ).save!
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
    :result => lambda { |character, target| 
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
    :result => lambda { |character, target|
      target = target.get
      found = false
      succeeded = false
      text = ["You ponder the #{target.name}."]
      Knowledge.all.each do |knowledge|
        if(knowledge.sources[target.type] && knowledge.sources[target.type].include?(target.id))
          found = true
          if(!character.knows?(knowledge.id) && !character.considers?(knowledge.id))
            character.consider(knowledge.id)
            succeeded = true
            text << knowledge.consider
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
    :success_modifiers => {
      :target => lambda { |character, target| 
        return -target.get.difficulty; 
      },
    },
    :result => lambda { |character, target|
      target = target.get
      if(target.type == 'knowledge' && Knowledge.find(target.id))
        if(character.knows?(target.id))
          return ActionOutcome.new(:already_investigated, target.name)
        else
          character.learn(target.id, 1)
          if(character.knows?(target.id))
            knowledge_research = Knowledge.find(target.id).research
          else
            knowledge_research = "There is still more to discover, however!"
          end
          return ActionOutcome.new(:success, target.name, knowledge_research)
        end
      else
        return ActionOutcome.new(:impossible, target.name)
      end
    },
    :messages => {
      :success => lambda { |args| "You dig deeper into the possibilities of #{args[0]}. #{args[1]}" },
      :already_investigated => lambda { |args| "You consider your ideas for #{args[0]} more fully, but don't think further investigation will accomplish anything here." },
      :failure => lambda { |args| "Your guesses about #{args[0]} might work didn't pan out, and you haven't made any progress this time around." },
      :impossible => lambda { |args| "Don't be absurd! You can't investigate #{args[0]}, you can only investigate ideas!" },
    },
    :requires => {
      :knowledge => ['cognition'],
      :target => {:idea=>['all']},
    },
    :target_prompt => "What would you like to investigate?",
    :base_cost => lambda { |character, target=nil| return 2 },
    :cost_modifiers => {
      :damage => 1,
      :despair => 1,
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
    :result => lambda { |character, target|
      target = target.get
      CharacterPossession.new(:character_id => character.id, :possession_id => "field").save!
      if(target.id == 'dolait')
        target.charges.times do
          CharacterPossession.new(:character_id => character.id, :possession_id => "dolait").save!
        end
      elsif(target.id == 'wildlands')
        Random.new.rand(1..4).times do
          found = Plant.all.sample
          possession_id = "food"
          CharacterPossession.new(
            :character_id => character.id, 
            :possession_id => possession_id,
            :possession_variant => PossessionVariant.find_or_do(found.id, possession_id, found.food_name)
          ).save!
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
    :base_cost => lambda { |character, target=nil| return 12 },
    :cost_modifiers => {
      :possession => [
        {:id => 'cutter', :modifier => -4},
      ],
      :damage => 10,
      :despair => 2,
    },
  }
)

Action.new("plant",
  { :name => "Sow Fields",
    :description => "You plant your seeds.",
    :base_success => 100,
    :result => lambda { |character, target|
      variant_key = target.possession_variant.key
      variant_name = Plant.find(variant_key).seed_name
      possession_id = "farm"
      CharacterPossession.new(
        :character_id => character.id, 
        :possession_id => possession_id,
        :possession_variant => PossessionVariant.find_or_do(variant_key, possession_id, variant_name),
        :charges => Possession.find(possession_id).max_charges,
      ).save!
      return ActionOutcome.new(:success, variant_name)
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
Action.new("harvest_fields",
  { :name => "Harvest Fields",
    :description => "You harvest the crops.",
    :base_success => 100,
    :result => lambda { |character, target|
      variant_key = target.possession_variant.key
      food_name = Plant.find(variant_key).food_name
      amount = 5
      if(!target.deplete(amount))
        amount = target.charges
        target.deplete(target.charges)
      end
      if(target.charges <= 0)
        target.destroy!
        CharacterPossession.new(:character_id => character.id, :possession_id => "field").save!
      end
      amount.times do
        possession_id = "food"
        CharacterPossession.new(
          :character_id => character.id, 
          :possession_id => possession_id,
          :possession_variant => PossessionVariant.find_or_do(variant_key, possession_id, food_name)
        ).save!
      end
      CharacterPossession.new(:character_id => character.id, :possession_id => "field").save!
      return ActionOutcome.new(:success, food_name, amount)
    },
    :messages => {
      :success => lambda { |args| "You harvest a field of #{args[0]}, gaining #{args[1]} food." },
      :failure => lambda { |args| "The harvest failed." },
      :impossible => lambda { |args| "You could not harvest." },
    },
    :requires => {
      :knowledge => ['basic_farming'],
      :target => {:possession=>['farm']},
    },
    :target_prompt => "What would you like to harvest?",
    :base_cost => lambda { |character, target=nil| return 2 },
    :cost_modifiers => {
      :possession => [
        {:id => 'cutter', :modifier => -1},
      ],
      :damage => 4,
      :despair => 1,
    },
  }
)

##########
# Morale #
##########
Action.new("play_with_toy",
  { :name => "Play With Toy",
    :description => "Spend some time playing with one of your toys.",
    :result => lambda { |character, target|
      # Success
      if(Random.new.rand(1..100) < 75)
        character.change_resolve(1)
        toy = character.character_possessions.where(:possession_id => "simple_toy").first
        if(Random.new.rand(1..100) < 25)
          toy.destroy!
          return ActionOutcome.new(:success_broken)
        else
          return ActionOutcome.new(:success)
        end
      else
        if(Random.new.rand(1..100) < 25)
          toy = character.character_possessions.where(:possession_id => "simple_toy").first
          toy.destroy!
          return ActionOutcome.new(:failure_broken)
        else
          return ActionOutcome.new(:failure)
        end
      end
    },
    :messages => {
      :success_broken => lambda { |args| "You play with your toys for a little while, but one of them breaks. At least you feel a bit better." },
      :success => lambda { |args| "You play with your toys for a little while. You feel better." },
      :failure_broken => lambda { |args| "Playing with your toys just isn't helping today, and to make it worse one of them has broken." },
      :failure => lambda { |args| "You're just not enjoying yourself. Your mind keeps getting distracted by other thoughts." },
      :impossible => lambda { |args| "You couldn't play with your toys." },
    },
    :requires => {
      :possession => [{:id => 'simple_toy', :quantity => 1},],
    },
    :base_cost => lambda { |character, target=nil| return 2 },
    :cost_modifiers => {
      :damage => 2,
      :despair => 0,
    },
  }
)

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
    :result => lambda { |character, target|
      if(target.deplete(1))
        CharacterPossession.new(:character_id => character.id, :possession_id => "dolait").save!
        if(target.charges <= 0)
          target.destroy!
          CharacterPossession.new(:character_id => character.id, :possession_id => "field").save!
        end
        if(character.possesses?("cutter"))
          return ActionOutcome.new(:success_cutter)
        else
          return ActionOutcome.new(:success)
        end
      else
        return ActionOutcome.new(:impossible, "There was no dolait remaining.") 
      end
    },
    :messages => {
      :success_cutter => lambda { |args| "You use your cutter to harvest some fresh dolait." },
      :success => lambda { |args| "You break off some fresh dolait branches." },
      :failure => lambda { |args| "The dolait you find proves too tough to gather." },
      :impossible => lambda { |args| "You couldn't gather dolait.#{ (args && !args.empty?) ? " "+args[0] : ""}" },
    },
    :requires => {
      :target => {
        :possession => ['dolait_source'],
      },
      :knowledge => ['basic_dolait'],
    },
    :base_cost => lambda { |character, target=nil| return 2 },
    :cost_modifiers => {
      :possession => [
        {:id => 'cutter', :modifier => -1},
      ],
      :damage => 4,
      :despair => 1,
    },
  }
)
Action.new("gather_tomatunk",
  { :name => "Gather Tomatunk",
    :description => "Go looking for chunks of tomatunk in the marsh.",
    :base_success_chance => 34,
    :result => lambda { |character, target|
      if(target.charges > 0)
        if(character.possesses?("basket"))
          amount_found = Random.new.rand(3)+1
          if(target.deplete(amount_found))
            amount_found.times do
              CharacterPossession.new(:character_id => character.id, :possession_id => "tomatunk").save!
            end
          else
            amount_found = target.charges
            target.deplete(amount_found)
            amount_found.times do
              CharacterPossession.new(:character_id => character.id, :possession_id => "tomatunk").save!
            end
          end
          if(amount_found > 1)
            return ActionOutcome.new(:basket_success, "#{amount_found.to_s} blocks")
          else
            return ActionOutcome.new(:basket_success, "1 block")
          end
        else
          target.deplete(1)
          CharacterPossession.new(:character_id => character.id, :possession_id => "tomatunk").save!
          return ActionOutcome.new(:success)
        end
      else
        return ActionOutcome.new(:failure) 
      end
    },
    :messages => {
      :basket_success => lambda { |args| "You wade until you find some tomatunk. You gather #{args[0]} of tomatunk into your basket." },
      :success => lambda { |args| "You wade through the mud and find a hefty block of tomatunk!" },
      :failure => lambda { |args| "You get soggy and dirty looking for tomatunk, but find only disappointment." },
      :impossible => lambda { |args| "You couldn't gather tomatunk." },
    },
    :requires => {
      :target => {
        :possession => ['tomatunk_source'],
      },
      :knowledge => [:basic_tomatunk],
    },
    :base_cost => lambda { |character, target=nil| return 2 },
    :cost_modifiers => {
      :damage => 2,
      :despair => 2,
    },
  }
)
Action.new("gather_wampoon",
  { :name => "Gather Wampoon",
    :description => "Go looking for wampoon in the barrens.",
    :base_success_chance => 25,
    :result => lambda { |character, target|
      if(target.deplete(1))
        CharacterPossession.new(:character_id => character.id, :possession_id => "wampoon").save!
        return ActionOutcome.new(:success)
      else
        return ActionOutcome.new(:failure)
      end
    },
    :messages => {
      :success => lambda { |args| "After hours of searching, you find some scraps of wampoon under a rock." },
      :failure => lambda { |args| "The barrens are as empty as they appear - you don't find a single shard of wampoon." },
      :impossible => lambda { |args| "You couldn't gather wampoon." },
    },
    :requires => {
      :target => {
        :possession => ['wampoon_source'],
      },
      :knowledge => [:basic_wampoon],
    },
    :base_cost => lambda { |character, target=nil| return 1 },
    :cost_modifiers => {
      :damage => 2,
      :despair => 2,
    },
  }
)

############
# Crafting #
############
Action.new("craft_basket",
  { :name => "Craft Basket",
    :description => "Craft a simple tool to aid in gathering.",
    :base_success_chance => 50,
    :success_modifiers => {
      :possession => [
        {:id => 'shaper_a', :modifier => 15},
        {:id => 'shaper_b', :modifier => 15},
        {:id => 'shaper_c', :modifier => 15},
      ],
    },
    :result => lambda { |character, target|
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
    :success_modifiers => {
      :possession => [
        {:id => 'shaper_a', :modifier => 15},
        {:id => 'shaper_b', :modifier => 15},
        {:id => 'shaper_c', :modifier => 15},
      ],
    },
    :result => lambda { |character, target|
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
    :success_modifiers => {
      :possession => [
        {:id => 'shaper_a', :modifier => 15},
        {:id => 'shaper_b', :modifier => 15},
        {:id => 'shaper_c', :modifier => 15},
      ],
    },
    :result => lambda { |character, target|
      CharacterPossession.new(:character_id => character.id, :possession_id => "shaper_a").save!
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
    :success_modifiers => {
      :possession => [
        {:id => 'shaper_a', :modifier => 15},
        {:id => 'shaper_b', :modifier => 15},
        {:id => 'shaper_c', :modifier => 15},
      ],
    },
    :result => lambda { |character, target|
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
    :success_modifiers => {
      :possession => [
        {:id => 'shaper_a', :modifier => 15},
        {:id => 'shaper_b', :modifier => 15},
        {:id => 'shaper_c', :modifier => 15},
      ],
    },
    :result => lambda { |character, target|
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
Action.new("craft_toy",
  { :name => "Craft Toy",
    :description => "Craft a simple toy.",
    :base_success_chance => 75, 
    :success_modifiers => {
      :possession => [
        {:id => 'shaper_a', :modifier => 25},
        {:id => 'shaper_b', :modifier => 25},
        {:id => 'shaper_c', :modifier => 25},
      ],
    },
    :result => lambda { |character, target|
      CharacterPossession.new(:character_id => character.id, :possession_id => "simple_toy").save!
      return ActionOutcome.new(:success)
    },
    :messages => {
      :success => lambda { |args| "You craft a simple toy." },
      :failure => lambda { |args| "The toy you made is already falling apart by the time you finish it. It's worthless." },
      :impossible => lambda { |args| "You don't have the materials to craft a toy." },
    },
    :consumes => [{:id => "dolait", :quantity => 1}],
    :requires => {
      :knowledge => [:craft_toy],
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
