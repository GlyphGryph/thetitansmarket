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
    }
  }
)
