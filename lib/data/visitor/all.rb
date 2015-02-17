Visitor.new("being",
  { :name => "Being",
    :description => "This strange being seems to have no interest in you.",
    :anger => 0,
    :health => 4,
    :fear => 0,
    :act => lambda { |instance|
      pool = DrawPool.new
      if(instance.fear <= 0 && instance.anger <= 0)
        pool.add_tickets(:depart, 1)
        pool.add_tickets(:idle, 2)
        if(instance.world.character_possessions.count > 0)
          pool.add_tickets(:target_item, 1)
        else
          pool.add_tickets(:idle, 1)
        end
        if(instance.world.characters.count > 0)
          pool.add_tickets(:target_character, 1)
        else
          pool.add_tickets(:idle, 1)
        end
      end

      if(instance.fear > 0)
        pool.add_tickets(:flee, instance.fear)
      end
      if(instance.anger > 0)
        pool.add_tickets(:attack, instance.anger)
      end

      drawn = pool.draw
      # Depart
      if(drawn == :depart)
        instance.world.broadcast("event", "The being grows bored and wanders off.")
        instance.depart
      elsif(drawn == :idle)
        instance.world.broadcast("event", "The being simply stands there.")
      elsif(drawn == :target_character)
        new_target = instance.world.characters.sample
        instance.change_target_to(new_target)
        instance.world.broadcast("event", "The being looks at #{new_target.get_name} a bit closer.")
      elsif(drawn == :target_item)
        new_target = instance.world.character_possessions.sample
        instance.change_target_to(new_target)
        instance.world.broadcast("event", "The being looks at the #{new_target.get_name} a bit closer.")
      elsif(drawn == :flee)
        instance.world.broadcast("event", "The being flees haphazardly, disappearing into the underbrush and not looking back.")
        instance.depart
      elsif(drawn == :attack)
        instance.world.broadcast("event", "The being roars, and launches a brutal attack against #{instance.target.get_name}", :exceptions => [instance, instance.target])
        instance.target.record("event", "The being roars, and launches a brutal attack at you!")
        instance.attack(instance.target)
      else
        instance.world.broadcast("event", "THERE'S SOMETHING WRONG! THERE'S SOMETHING WRONG! THIS SHOULDN'T BE POSSIBLE!")
      end
    },
    :defense => {
      :always => lambda { |instance, attacker|
        instance.change_anger(1)
        instance.change_target_to(attacker)
      },
      :success => lambda{ |instance, attacker|
        instance.change_fear(-1)
      },
      :counter => {
        :success => lambda{ |instance, attacker|
          instance.change_anger(1)
          instance.change_fear(-1)
        },
        :failure => lambda{ |instance, attacker|
          instance.change_fear(1)
        }
      }
    },
    :attack => {
      :success_chance => 80,
      :wound_type => :wound,
      :counter => {
        :chance => 50,
        :success => lambda{ |instance, attacker|
          instance.change_anger(1)
          instance.change_fear(-1)
        },
        :failure => lambda{ |instance, attacker|
          instance.change_fear(1)
        }
      }
    },
    :scared => lambda { |instance, character|
      character.record("important", "You shout and wave your arms at the creature.")
      pool = DrawPool.new
      pool.add_tickets(:stare, 2)
      pool.add_tickets(:growl, 1)
      pool.add_tickets(:spook, 4)
      drawn = pool.draw
      if(drawn==:stare)
        character.record("passive", "The being stares at you impassively.")
      elsif(drawn==:growl)
        instance.change_anger(1)
        character.record("failure", "The being growls angrily at you.")
      else
        instance.change_fear(rand(1..3))
        character.record("success", "The being seems surprised.")
      end
    },
    :butchered => lambda { |instance, character|
      variant_id = "meat"
      possession_id = "food"
      CharacterPossession.new(
        :character_id => character.id, 
        :possession_id => possession_id,
        :possession_variant => PossessionVariant.find_or_do(variant_id, possession_id, Possession.find(possession_id).variant_name(variant_id)),
      ).save!
      character.record("event", "You turn the slaughtered Being into delicious meat.")
    },
  },
)
Visitor.new("predator",
  { :name => "Predator",
    :description => "A vicious looking predator.",
    :anger => 0,
    :health => 6,
    :fear => 0,
    :spawn => lambda { |instance|
        prey = instance.world.world_visitors.where(:visitor_id => "prey")
        if(prey.empty?)
          new_target = instance.world.characters.sample
        else
          new_target = prey.sample
        end
        instance.change_target_to(new_target)
    },
    :act => lambda { |instance|
      pool = DrawPool.new
      if(instance.target && !instance.target.dead?)
        if(instance.fear <= 0 && instance.anger <= 0)
          pool.add_tickets(:depart, 1)
        end
        pool.add_tickets(:attack, 2)
        if(!instance.target.is_a?(WorldVisitor))
          prey = instance.world.world_visitors.where(:visitor_id => "prey")
          if(!prey.empty?)
            pool.add_tickets(:hunt_prey, 1)
          end
        end

        if(instance.fear > instance.anger)
          pool.add_tickets(:flee, instance.fear - instance.anger)
        end
        if(instance.anger > 0)
          pool.add_tickets(:attack, instance.anger)
        end
      else
        pool.add_tickets(:depart, 1)
        prey = instance.world.world_visitors.where(:visitor_id => "prey")
        if(!prey.empty?)
          pool.add_tickets(:hunt_prey, 1)
        else
          pool.add_tickets(:change_target, 1)
        end
      end

      drawn = pool.draw

      if(drawn == :depart)
        instance.world.broadcast("event", "The predator has decided to move on for whatever inscrutable reason.")
        instance.depart
      elsif(drawn == :flee)
        instance.world.broadcast("event", "The predator has fled in fear.")
        instance.depart
      elsif(drawn == :attack)
        instance.world.broadcast("event", "The predator pounces on #{instance.target.get_name}, snarling and clawing.", :exceptions => [instance, instance.target])
        Message.send(instance.target, "event", "The predator pounces on you, snarling and clawing!")
        3.times do
          if(!instance.target.dead?)
            instance.attack(instance.target)
          end
        end
      elsif(drawn == :change_target)
        new_target = instance.world.characters.sample
        instance.change_target_to(new_target)
      elsif(drawn == :hunt_prey)
        new_target = instance.world.world_visitors.where(:visitor_id => "prey").sample
        instance.change_target_to(new_target)
      else
        instance.world.broadcast("event", "THERE'S SOMETHING WRONG! THERE'S SOMETHING WRONG! THIS SHOULDN'T BE POSSIBLE!")
      end
    },
    :defense => {
      :always => lambda { |instance, attacker|
        instance.change_anger(1)
        instance.change_target_to(attacker)
      },
    },
    :attack => {
      :success_chance => 75,
      :wound_type => :wound,
      :always => lambda { |instance, attacker|
        instance.change_anger(1)
      },
      :counter => {
        :chance => 75,
      }
    },
    :scared => lambda { |instance, character|
      character.record("important", "You shout and wave your arms at the predator.")
      character.record("failure", "The predator snarls in anger.")
    },
    :butchered => lambda { |instance, character|
      variant_id = "meat"
      possession_id = "food"
      3.times do
        CharacterPossession.new(
          :character_id => character.id, 
          :possession_id => possession_id,
          :possession_variant => PossessionVariant.find_or_do(variant_id, possession_id, Possession.find(possession_id).variant_name(variant_id)),
        ).save!
      end
      ["skin","skin","bone","bone"].each do |possession_id|
        CharacterPossession.new(:character_id => character.id, :possession_id => possession_id).save!
      end

      character.record("event", "You turn the slaughtered Predator into delicious meat.")
    },
  },
)
Visitor.new("prey",
  { :name => "Grazer",
    :description => "A dim looking herbivore shuffles about, gnawing on the scenery.",
    :anger => 0,
    :health => 3,
    :fear => 0,
    :spawn => lambda { |instance|
    },
    :act => lambda { |instance|
      pool = DrawPool.new
      if(instance.fear <= 0 && instance.anger <= 0)
        pool.add_tickets(:idle, 2)
        pool.add_tickets(:depart, 1)
      end
      if(instance.anger > 0 && instance.target && !instance.target.dead?)
        pool.add_tickets(:attack, instance.anger)
      end
      if(instance.fear > 0)
        pool.add_tickets(:flee, instance.fear)
      end

      drawn = pool.draw

      if(drawn == :depart)
        instance.world.broadcast("event", "The grazer wanders off.")
        instance.depart
      elsif(drawn == :idle)
        instance.world.broadcast("event", "The grazer nibbles on some leaves.")
      elsif(drawn == :flee)
        instance.world.broadcast("event", "The grazer has fled in fear.")
        instance.depart
      elsif(drawn == :attack)
        instance.world.broadcast("event", "The grazer shrieks in fear, and charges!", :exceptions => [instance, instance.target])
        Message.send(instance.target, "event", "The grazer charges at you, shrieking!")
        if(!instance.target.dead?)
          instance.attack(instance.target)
        end
      else
        instance.world.broadcast("event", "THERE'S SOMETHING WRONG! THERE'S SOMETHING WRONG! THIS SHOULDN'T BE POSSIBLE!")
      end
    },
    :defense => {
      :always => lambda { |instance, attacker|
        instance.change_anger(1)
        instance.change_fear(2)
        instance.change_target_to(attacker)
      },
    },
    :attack => {
      :success_chance => 75,
      :wound_type => :wound,
      :always => lambda { |instance, attacker|
        instance.change_anger(1)
      },
      :counter => {
        :chance => 25,
      }
    },
    :scared => lambda { |instance, character|
      character.record("important", "You shout and wave your arms at the grazer.")
      character.record("failure", "The grazer is startled!")
      if(rand(1..4) > 1)
        instance.change_fear(1)
      else
        instance.change_anger(1)
      end
    },
    :butchered => lambda { |instance, character|
      variant_id = "meat"
      possession_id = "food"
      4.times do
        CharacterPossession.new(
          :character_id => character.id, 
          :possession_id => possession_id,
          :possession_variant => PossessionVariant.find_or_do(variant_id, possession_id, Possession.find(possession_id).variant_name(variant_id)),
        ).save!
      end
      ["skin","skin","skin","bone","bone", "bone", "bone"].each do |possession_id|
        CharacterPossession.new(:character_id => character.id, :possession_id => possession_id).save!
      end
      character.record("event", "You turn the slaughtered grazer into delicious meat.")
    },
  },
)
