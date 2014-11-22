Visitor.new("being",
  { name: "Being",
    description: "This strange being seems to have no interest in you.",
    result: lambda { |instance|
      if(rand(1..3) == 1)
        instance.world.broadcast("event", "The being grows bored and wanders off.")
        instance.depart
        return true
      else
        instance.world.broadcast("event", "The being simply stands there.")
        return false
      end
    }
  }
)
