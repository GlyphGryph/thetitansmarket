class Condition
  extend CollectionTracker
  attr_reader :id, :name, :description, :result

  def initialize(id, params={})
    @id = id
    @name = params[:name] || "Name Error"
    @description = params[:description] || "Description Error"
    @result = params[:result] || lambda { |character| return "Condition Result Error" }
    self.class.add(@id, self)
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
        character.damage(1)
        return "You suffer from starvation."
      end
    },
  }
)

