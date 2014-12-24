Visitor.new("being",
  { :name => "Being",
    :description => "This strange being seems to have no interest in you.",
    :anger => 0,
    :health => 4,
    :fear => 0,
    :result => lambda { |instance|
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
        instance.target.record("event", "The being roars, and launches a brutal attack at you!")
        instance.attack(instance.target)
      else
        instance.world.broadcast("event", "THERE'S SOMETHING WRONG! THERE'S SOMETHING WRONG! THIS SHOULDN'T BE POSSIBLE!")
      end
    },
    :attacked => {
      :always => lambda { |instance, attacker|
        instance.change_anger(10)
        instance.change_target_to(attacker)
      },
      :success => lambda{ |instance, attacker, amount|
        instance.change_fear(amount)
      },
      :failure => lambda{ |instance, attacker|
      },
    },
    :attack => {
      :success_chance => 80,
      :success_message => "The Being strikes you with a roar.",
      :fail_message => "The Being swings at you with anger in it's eyes, but the strike goes wide.",
      :wound_type => :wound,
    },
    :counter => {
      :chance => 50,
      :success_message => "The Being roars in anger and rushes at you, striking you!",
      :fail_message => "The Being roars in anger and rushes at you, but misses!",
      :success => lambda{ |instance, attacker|
        instance.change_anger(1)
        instance.change_fear(-1)
      },
      :failure => lambda{ |instance, attacker|
        instance.change_fear(1)
      }
    },
    :scared => lambda { |instance, character|
      character.record("important", "You shout and wave your arms at the creature.")
      pool = DrawPool.new
      pool.add_tickets(:stare, 2)
      pool.add_tickets(:growl, 1)
      poolaracter.record("important", "You shout and wave your arms at the creature.")
      add_tickets(:spook, 1)
      drawn = pool.draw
      if(drawn==:stare)
        character.record("passive", "The being stares at you impassively.")
      elsif(drawn==:growl)
        instance.change_anger(1)
        character.record("failure", "The being growls angrily at you.")
      else
        instance.change_fear(1)
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
