# Format for new activities
# 'id', {:name => 'Name', :description=>"Multi-word description.", 
# :result => lambda {|character, character_activity| return "Some string based on what happens, possibly conditional on character state" }, // Takes a character, returns a string
# :cost => lambda {|character| if(character.loves_chicken) return 5; else return 6;} // Takes a character, returns a digit
# }

Activity.new("play",
  { :name=>"Play", 
    :description=>"Play around with another character, increasing your happiness a bit. Costs 2 vigor, grants 1 resolve.", 
    :result => lambda { |character, target|
      if(target.has_trait?("pretty_face"))
        character.change_resolve(2)
      else
        character.change_resolve(1)
      end
      character.save!
      if(character.has_trait?("pretty_face"))
        target.change_resolve(2)
      else
        target.change_resolve(1)
      end
      target.save!
      return true
    },
    :messages => {
      :success => lambda { |args| "You play with #{args[0]} for a while, and the world doesn't seem to rest nearly so heavily on your shoulders for a while." },
    },
    :character_addendum => lambda { |character, target|
      if(character.has_trait?("pretty_face"))
        return "Your pretty face will grant #{target.get.name} a +1 resolve bonus!"
      end
      return false
    },
    :target_addendum => lambda { |character, target|
      if(target.has_trait?("pretty_face"))
        return "#{target.get.name} has a pretty face, and will grant you a +1 resolve bonus!"
      end
      return false
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
