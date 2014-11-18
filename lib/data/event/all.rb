Event.new("nothing",
  :description => "Nothing happens.",
  :tickets => 4,
  :silent => true,
)
Event.new("light",
  :description => "There is a distant flash of light in the distance.",
  :tickets => 10,
  :creates => {
    :occurence => {
      :characters => :all,
      :outcomes => [
        { 
          :tickets => 1,
          :result => lambda { |character|
            character.change_resolve(1)
            character.record("passive", "You aren't sure why, but you feel a bit better for having seen it.")
            character.save!
          },
        },
        { 
          :tickets => 1,
        },
      ]
    }
  }
)
Event.new("harsh_weather",
  :description => "The wind picks up and rain begins to fall. It looks like it's going to be bad for a while...",
  :creates => {
    :situation => {
      :id => "harsh_weather",
      :duration => 1
    }
  },
  :tickets => 1,
)
