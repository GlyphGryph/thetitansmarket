class Condition
  extend CollectionTracker
  attr_reader :id, :name, :description

  def initialize(id, params={})
    @id = id
    @name = params[:name] || "Name Error"
    @description = params[:description] || "Description Error"
    @result = params[:result] || lambda { |character| return "Condition Result Error" }
    self.class.add(@id, self)
  end

  def result(character)
    @result.call(character)
  end

  def type
    return "condition"
  end
end 

# Format for new items
# 'id', {:name => 'Name', :description=>"Multi-word description."
# :result => lamda describing the code that will execute each turn for those with this condition
Condition.new("hunger",
  { :name=>"Hunger", 
    :description=>"You're in the mood for food.", 
    :result => lambda { |character| 
      if(character.eat)
        return "You gobble up a unit of food."
      else 
        character.change_hp(-3)
        character.change_happy(-1)
        return "You suffer from starvation."
      end
    },
  }
)

Condition.new("weariness",
  { :name=>"Weariness", 
    :description=>"Life keeps on keeping on.", 
    :result => lambda { |character| 
      character.change_happy(-1)
      return "As time passes, your feel a weight settle on your soul."
    },
  }
)
Condition.new("resilience",
  { :name=>"Resilience", 
    :description=>"Pull yourself together, kid.", 
    :result => lambda { |character| 
      character.change_hp(1)
      return "You feel your body recovering from the damage it's sustained."
    },
  }
)
Condition.new("pure_grit",
  { :name=>"Pure Grit", 
    :description=>"You're holding yourself together with nothing but willpower and determination at this point, but it can't last much longer...", 
    :result => lambda { |character| 
      return "This is a result."
    },
  }
)
