Visitor.new("being",
  { name: "Being",
    description: "This strange being seems to have no interest in you.",
    result: lambda { |instance|
      if(rand(1..3) == 1)
        instance.depart
        return true
      else
        return false
      end
    }
  }
)
