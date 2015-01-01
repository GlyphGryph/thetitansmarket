Event.new("nothing",
  :tickets => 5,
  :description => "Nothing happens.",
  :silent => true,
)
Event.new("light",
  :tickets => 1,
  :description => "There is a distant flash of light in the distance.",
  :creates => {
    :occurence => {
      :characters => :all,
      :outcomes => [
        { 
          :tickets => 1,
          :result => lambda { |character|
            character.change_resolve(3)
            character.save!
            character.record("passive", "You aren't sure why, but you feel a bit better for having seen it.")
          },
        },
        { 
          :tickets => 1,
        },
      ]
    }
  }
)
Event.new("lucky_find",
  :tickets => 1,
  :description => "Someone finds an item on the ground.",
  :silent => true,
  :creates => {
    :occurence => {
      :characters => 1,
      :outcomes => [
        { 
          :result => lambda { |character|
            CharacterPossession.new(:character_id => character.id, :possession_id => "generic_object").save!
            character.record("event", "You find a strange object just lying on the ground!")
          },
        },
      ]
    }
  }
)
Event.new("stolen_food",
  :tickets => 1,
  :description => "It looks like some animals ran off with a few pieces of food.",
  :silent => true,
  :creates => {
    :occurence => {
      :characters => 1,
      :outcomes => [
        { 
          :result => lambda { |character|
            foods = character.character_possessions.where(:possession_id => "food")
            if(foods.empty?)
              character.record("event", "A strange animal scurries off into the underbrush.")
            else
              foods.sample.destroy!
              character.record("event", "A strange animal scurries off into the underbrush. Some of your food has gone missing!")
            end
          },
        },
      ]
    }
  }
)
Event.new("harsh_weather",
  :tickets => 1,
  :description => "The wind picks up and rain begins to fall. It looks like it's going to be bad for a while...",
  :creates => {
    :situation => {
      :id => "harsh_weather",
      :duration => 1
    }
  },
)
Event.new("visitor",
  :tickets => 1,
  :description => "A strange being lurks at the edge of camp.",
  :creates => {
    :visitor => {
      :id => "being"
    }
  },
)
Event.new("predator",
  :tickets => 1,
  :description => "A vicious looking predator has been seen prowling the area. It seems to have caught an interesting scent.",
  :creates => {
    :visitor => {
      :id => "predator"
    }
  },
)
Event.new("prey",
  :tickets => 1,
  :description => "A clumsy herbivore has wandered in and begun gnawing on the scenery.",
  :creates => {
    :visitor => {
      :id => "prey"
    }
  },
)
