# Format for new activities
# 'id', {:name => 'Name', :description=>"Multi-word description.", 
# :result => lambda {|character, character_activity| return "Some string based on what happens, possibly conditional on character state" }, // Takes a character, returns a string
# :cost => lambda {|character| if(character.loves_chicken) return 5; else return 6;} // Takes a character, returns a digit
# }

Activity.new("play",
  { :name=>"Play", 
    :description=>"Play around with another character, increasing your happiness a bit. Costs 2 vigor, grants 1 resolve.", 
    :result => lambda { |character, target|
      character.change_resolve(1)
      character.save!
      target.change_resolve(1)
      target.save!
      return true
    },
    :messages => {
      :success => lambda { |args| "You play with #{args[0]} for a while, and the world doesn't seem to rest nearly so heavily on your shoulders for a while." },
    },
    :cost => {
      :accept => 2,
      :offer => 2,
    },
    :available => lambda { |character|
      return character.knows?("play")
    },
  }
)


Activity.new("teach",
  { :name=>"Teach", 
    :description=>"Teach another person a piece of knowledge you know, for six vigor.", 
    :result => lambda { |character, target|
      character.change_resolve(1)
      character.save!
      target.change_resolve(1)
      target.save!
      return true
    },
    :messages => {
      :success => lambda { |args| "You play with #{args[0]} for a while, and the world doesn't seem to rest nearly so heavily on your shoulders for a while." },
    },
    :cost => {
      :accept => 2,
      :offer => 2,
    },
    :available => lambda { |character|
      return character.knows?("play")
    },
  }
)
