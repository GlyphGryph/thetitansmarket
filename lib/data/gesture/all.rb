Gesture.new("wave",
  { :name => "Wave",
    :description => "Wave at the other person.",
    :second_person => "wave at",
    :third_person => "waves at",
  }
)
Gesture.new("point",
  { :name => "Point",
    :description => "Point at something.",
    :second_person => "point at",
    :third_person => "points at",
    :target_prompt => "What would you like to point at?",
    :requires_target => true,
    :valid_targets => {:possession=>['all'], :character=>['all'], :body=>['all']},
  }
)
Gesture.new("wink",
  { :name => "Wink",
    :description => "Wink at someone.",
    :second_person => "wink at",
    :third_person => "winks at",
    :target_prompt => "Who would you like to wink at?",
    :requires_target => true,
    :valid_targets => {:character=>['all']},
  }
)
Gesture.new("hug",
  { :name => "Hug",
    :description => "Hug someone.",
    :second_person => "hug",
    :third_person => "hugs",
    :target_prompt => "Who would you like to wink at?",
    :requires_target => true,
    :valid_targets => {:character=>['all']},
  }
)
Gesture.new("gnaw",
  { :name => "Gnaw",
    :description => "Gnaw on something.",
    :second_person => "gnaw on",
    :third_person => "gnaws on",
    :target_prompt => "What would you like to gnaw on?",
    :requires_target => true,
    :valid_targets => {:possession=>['all'], :character=>['all'], :body=>['all']},
  }
)
Gesture.new("rub",
  { :name => "Rub",
    :description => "Rub something.",
    :second_person => "rub",
    :third_person => "rubs",
    :target_prompt => "What would you like to gnaw on?",
    :requires_target => true,
    :valid_targets => {:possession=>['all'], :body=>['all']},
  }
)
Gesture.new("shake",
  { :name => "Shake",
    :description => "Shake something.",
    :second_person => "shake",
    :third_person => "shakes",
    :target_prompt => "What would you like to shake?",
    :requires_target => true,
    :valid_targets => {:possession=>['all'], :character=>['all'], :body=>['all']},
  }
)
Gesture.new("look",
  { :name => "Look",
    :description => "Look at something.",
    :second_person => "look at",
    :third_person => "looks at",
    :target_prompt => "What would you like to look at?",
    :requires_target => true,
    :valid_targets => {:possession=>['all'], :character=>['all'], :body=>['all']},
  }
)
Gesture.new("scowl",
  { :name => "Scowl",
    :description => "Scowl at something.",
    :second_person => "scowl at",
    :third_person => "scowls at",
    :target_prompt => "What would you like to scowl at?",
    :requires_target => true,
    :valid_targets => {:possession=>['all'], :character=>['all'], :body=>['all']},
  }
)
Gesture.new("tounge",
  { :name => "Tongue",
    :description => "Stick your tongue out at something.",
    :second_person => "stick your tongue out at",
    :third_person => "sticks their tongue out at",
    :target_prompt => "What would you like to stick your tongue out at?",
    :requires_target => true,
    :valid_targets => {:possession=>['all'], :character=>['all']},
  }
)
Gesture.new("growl",
  { :name => "Growl",
    :description => "Growl at something.",
    :second_person => "growl at",
    :third_person => "growls at",
    :target_prompt => "What would you like to growl at?",
    :requires_target => true,
    :valid_targets => {:possession=>['all'], :character=>['all']},

  }
)
Gesture.new("scream",
  { :name => "Scream",
    :description => "Scream!",
    :second_person => "scream",
    :third_person => "screams",
    :target_prompt => "What would you like to scream at?",
    :requires_target => false,
  }
)
Gesture.new("grimace",
  { :name => "Grimace",
    :description => "Grimace.",
    :second_person => "grimace",
    :third_person => "grimaces",
    :target_prompt => "What would you like to grimace at?",
    :requires_target => false,
  }
)
Gesture.new("smile",
  { :name => "Smile",
    :description => "Smile.",
    :second_person => "smile",
    :third_person => "smiles",
    :target_prompt => "What would you like to smile at?",
    :requires_target => false,
  }
)
Gesture.new("laugh",
  { :name => "Laugh",
    :description => "Laugh.",
    :second_person => "laugh",
    :third_person => "laughs",
    :target_prompt => "What would you like to laugh at?",
    :requires_target => false,
  }
)
Gesture.new("cry",
  { :name => "Cry",
    :description => "Cry a little.",
    :second_person => "cry",
    :third_person => "cries",
    :target_prompt => "What would you like to cry about?",
    :requires_target => false,
  }
)
Gesture.new("shrug",
  { :name => "Shrug",
    :description => "Shrug your shoulders.",
    :second_person => "shrug",
    :third_person => "shrugs",
    :target_prompt => "What would you like to shrug at?",
    :requires_target => false,
  }
)
Gesture.new("raise",
  { :name => "Raise",
    :description => "Raise something.",
    :second_person => "raise",
    :third_person => "raises",
    :addendum => "into the air",
    :target_prompt => "What would you like to raise?",
    :requires_target => true,
    :valid_targets => {:body=>['all']},
  }
)
