Event.new("nothing",
  :description => "Nothing happens.",
  :tickets => 4,
  :silent => true,
)
Event.new("something",
  :description => "Something happens.",
  :tickets => 1,
)
Event.new("harsh_weather",
  :description => "The wind picks up and rain begins to fall. It looks like it's going to be bad for a while...",
  :creates => {
    :situation => {
      :id => "harsh_weather",
      :duration => 1
    }
  },
  :tickets => 10,
)
