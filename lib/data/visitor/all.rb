Visitor.new("being",
  { name: "Being",
    description: "This strange being seems to have no interest in you.",
    result: lambda { |instance|
      pool = DrawPool.new
      pool.add_tickets(:depart, 1)
      pool.add_tickets(:idle, 2)

      if(instance.world.characters.count > 0)
        pool.add_tickets(:target_character, 1)
      else
        pool.add_tickets(:idle, 1)
      end

      if(instance.world.character_possessions.count > 0)
        pool.add_tickets(:target_item, 1)
      else
        pool.add_tickets(:idle, 1)
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
        instance.target = new_target
        instance.save!
        instance.world.broadcast("event", "The being looks at #{new_target.get_name} a bit closer.")
      elsif(drawn == :target_item)
        new_target = instance.world.character_possessions.sample
        instance.target = new_target
        instance.save!
        instance.world.broadcast("event", "The being looks at the #{new_target.get_name} a bit closer.")
      else
        instance.world.broadcast("event", "THERE'S SOMETHING WRONG! THERE'S SOMETHING WRONG! THIS SHOULDN'T BE POSSIBLE!")
      end
    },
    :attacked => lambda { |instance, character|
      character.record("important", "You attacked the being.")
      if(rand(1..3)!=1)
        character.record("success", "You hurt the being!")
      else
        character.record("failure", "You fail to injure the being!")
      end
      if(rand(1..3)==1)
        character.record("failure", "The being hurt you!")
        character.hurt(1)
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
        character.record("failure", "The being growls angrily at you.")
      else
        character.record("success", "The being seems surprised.")
      end
    },
  },
)
