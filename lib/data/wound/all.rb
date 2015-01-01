# Rules for decay targets:
# An array of options. Each option will be attempted in turn.
# Difficulty determines the odds of failing to achieve this goal. A difficulty of zero or a difficulty not set always suceeds.
# If no option succeeds, or an option with no id, the wound decays to nothing.
# An option with no message is silent, otherwise the owner of the wound receives the message (if they can).
WoundTemplate.load([
  { :id => :error_wound,
    :name => "Mysterious Wound",
    :description => "This wound is impossible to acquire.",
    :damage => 0,
    :decay_targets => [
    ],
  },
  { :id => :wound,
    :name => "Wound",
    :description => "This is a pretty nasty looking gash.",
    :damage => 1,
    :decay_targets => [
      { :id => :healed_wound,
        :message => "Your gash has closed, though it is still tender.",
        :difficulty => 5,
      },
      { :id => :fresh_scar,
        :message => "Your gash has begun to heal, but unevenly, and has formed a scar.",
        :difficulty => 7,
      },
      { :id => :infected_wound,
        :message => "Your gash has become infected, and hurts like hell.",
      }
    ],
  },
  { :id => :infected_wound,
    :name => "Festering Wound",
    :description => "This wound has become infected.",
    :damage => 1,
    :decay_targets => [
      { :id => :fresh_scar,
        :message => "The infection has abated, though it left a jagged and irregular scar.",
        :difficulty => 7,
      },
      { :id => :infected_wound },
    ],
  },
  { :id => :healed_wound,
    :name => "Healing Wound.",
    :description => "This wound is healing nicely.",
    :decay_targets => [
    ],
  },
  { :id => :fresh_scar,
    :name => "Fresh Scar",
    :description => "Your injury has formed a jagged red scar.",
    :decay_targets => [
      { :id => :scar }
    ],
  },
  { :id => :scar,
    :name => "Scar",
    :description => "A faded scar from an old wound.",
    :decay_targets => [
      { :id => :scar }
    ]
  }
])
