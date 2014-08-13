class Activity
  extend CollectionTracker
  attr_reader :id, :name, :description, :cost, :available, :target_prompt, :requires_target

  def initialize(id, params={})
    @id = id
    @name = params[:name] || "Name Error"
    @description = params[:description] || "Description Error"
    @available = params[:available] || lambda { |character| return true }
    @result = params[:result] || lambda { |character, target| return "Function error." }
    self.class.add(@id, self)
  end

  def available?(character)
    return @available.call(character)
  end

  def result(character, target)
    return @result.call(character, target)
  end

  def type
    return "activity"
  end
end

# Format for new activitys
# 'id', {:name => 'Name', :description=>"Multi-word description.", 
# :result => lambda {|character, character_activity| return "Some string based on what happens, possibly conditional on character state" }, // Takes a character, returns a string
# :cost => lambda {|character| if(character.loves_chicken) return 5; else return 6;} // Takes a character, returns a digit
# }

Activity.new("play",
  { :name=>"Play", 
    :description=>"Play around with another character, increasing your happiness a bit. Costs 2 ap, grants 1 happy.", 
    :result => lambda { |character, target|
      ap_cost = 2
      if(character.ap > ap_cost && target.ap > ap_cost)
        character.change_happy(1)
        character.change_ap(-2)
        character.save!
        target.change_happy(1)
        target.change_ap(-2)
        target.save!
        return true;
      end
      return false;
    },
    :available => lambda { |character|
      return character.knows?("play")
    },
  }
)
