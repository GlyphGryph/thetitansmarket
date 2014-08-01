class Action
  extend CollectionTracker
  attr_reader :id, :name, :description, :result, :cost

  def initialize(id, params={})
    @id = id
    @name = params[:name] || "Name Error"
    @description = params[:description] || "Description Error"
    @result = params[:result] || lambda { |character| return "Function error." }
    @cost = params[:cost] || lambda { |character| return 1 }
    self.class.add(@id, self)
  end
end

# Format for new actions
# 'id', {:name => 'Name', :description=>"Multi-word description.", 
# :result => lambda {|character| return "Some string based on what happens, possibly conditional on character state" }, // Takes a character, returns a string
# :cost => lambda {|character| if(character.loves_chicken) return 5; else return 6; } // Takes a character, returns a digit

Action.new("rest", 
  { :name=>"Rest", 
    :description=>"You relax.", 
    :result => lambda { |character| return "Zzzzzz... You rest a while." },
    :cost => lambda { |character| return 1 },
  }
)

Action.new("reminisce", 
  { :name=>"Reminisce", 
    :description=>"You think about the past.", 
    :result => lambda { |character| return "Sigh... You reminisce a while." },
    :cost => lambda { |character| return 2 },
  }
)

Action.new("forage",
  { :name=>"Forage", 
    :description=>"You think about the past.", 
    :result => lambda { |character|
      if(Random.rand(2)==0)
        CharacterPossession.new(:character_id => character.id, :possession_id => "food").save!
        foodlist = ["strawberries", "blueberries", "bearberries", "hackberries", "boisonberries", "grapes", "bananas",
                    "squash", "mushrooms", "oranges", "apples", "cranberries", "zuchinni", "cucumber", "chickens"]
        return "You forage through the underbrush and turn up some #{foodlist.sample}. Food!" 
      else
        return "You forage through the underbrush, but find only disappointment." 
      end
    },
    :cost => lambda { |character| return 1 },
  }
)

Action.new("explore", 
  { :name=>"Explore", 
    :description=>"You explore the wilds.", 
    :result => lambda { |character| 
      if(Random.rand(4)==0)
        CharacterPossession.new(:character_id => character.id, :possession_id => "generic_object").save!
        return "Tallyho! You explore a while, and discover a Generic Object just lying out in the open! You snatch it up." 
      else
        return "Tallyho! You explore a while, but turn up nothing." 
      end
    },
    :cost => lambda { |character| return 5 },
  }
)
