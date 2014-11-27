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
      if(instance.health < 4)
        pool.add_tickets(:flee, 4-instance.health)
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
        if(rand(1..3)!=1)
          instance.target.record("event", "The being roars, and launches a brutal attack at you!")
          instance.target.hurt(1)
        else
          instance.target.record("failure", "The being roars, and attacks! You somehow manage to fight it off!")
          instance.change_fear(1)
        end
        instance.change_anger(-1)
      else
        instance.world.broadcast("event", "THERE'S SOMETHING WRONG! THERE'S SOMETHING WRONG! THIS SHOULDN'T BE POSSIBLE!")
      end
    },
    :attacked => lambda { |instance, character|
      instance.change_anger(3)
      instance.change_target_to(character)
      character.record("important", "You attacked the being.")
      if(rand(1..3)!=1)
        instance.change_fear(1)
        instance.change_health(-1)
        character.record("success", "You hurt the being!")
      else
        character.record("failure", "You fail to injure the being!")
      end
      if(rand(1..3)==1)
        character.hurt(1)
        instance.change_anger(2)
        character.record("failure", "The being hurt you!")
      end
    },
    :scared => lambda { |instance, character|
      character.record("important", "You shout and wave your arms at the creature.")
      pool = DrawPool.new
      pool.add_tickets(:stare, 2)
      pool.add_tickets(:growl, 1)
      pool.add_tickets(:spook, 1)
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
  },
)
