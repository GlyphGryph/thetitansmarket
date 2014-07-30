class Action
  @@actions = {}
  class << self
    def all
      @@actions.values
    end

    def find(id)
      @@actions[id]
    end
  end

  attr_reader :id, :name, :description, :result, :cost

  def initialize(id, params={})
    @id = id
    @name = params[:name] || "Name Error"
    @description = params[:description] || "Description Error"
    @result = params[:result] || lambda { |character| return "Function error." }
    @cost = params[:cost] || lambda { |character| return 1 }
    @@actions[@id]=self
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

Action.new("explore", 
  { :name=>"Explore", 
    :description=>"You explore the wilds.", 
    :result => lambda { |character| return "Tallyho! You explore a while." },
    :cost => lambda { |character| return 5 },
  }
)
