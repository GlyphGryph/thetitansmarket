class Activity
  extend CollectionTracker
  attr_reader :id, :name, :description, :result, :cost, :available, :target_prompt, :requires_target

  def initialize(id, params={})
    @id = id
    @name = params[:name] || "Name Error"
    @description = params[:description] || "Description Error"
    @result = params[:result] || lambda { |character, target| return "Function error." }
    self.class.add(@id, self)
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
      ap_cost
      if(character.ap > ap_cost && target.ap > ap_cost)
        character.change_happy(1)
        character.save!
        target.change_happy(1)
        target.save!
        return true;
      end
      return false;
    },
  }
)
