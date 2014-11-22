Event.new("nothing",
  :tickets => 4,
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
  :description => "Someone find an item on the ground.",
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
  :description => "A vile force of darkness has arrived.",
  :creates => {
    :visitor => {
      :id => "being"
    }
  },
)
