#####################
# These functions are for interfacing with a body. The owner must possess a body for them to work
#
# Having a body allows the owner to attack and be attacked, and to spend vigor on doing actions
# It also tracks whether the owner is dead, and allows the owner to be butchered if so
#####################
module BodyInterface
  def self.included(base)
    base.class_eval do
      has_one :body, :as => :owner, :dependent => :destroy
      after_create :add_body
    end
  end

  def starting_health
    return 10
  end
  def attack_success_chance
    return 100
  end
  def counter_success_chance
    return 50
  end
  def recovery_value
    return 0
  end
  def attacks_require_vigor
    false
  end

  def add_body
    self.body = Body.new(:max_health => self.starting_health)
    self.body.save!
  end

  def attack(target)
    if(attacks_require_vigor)
      self.require_vigor(self.attack_cost) do
        self.execute_attack(target)
      end
    else
      self.execute_attack(target)
    end
  end

  def execute_attack(target)
    if(target.dead?)
      Message.send(self, 'important', "You can't attack the dead.")
    elsif(!target.dead?)
      self.attack_happens(target)
      target.defense_happens(self)
      if(rand(1..100) <= self.attack_success_chance)
        self.attack_succeeds(target)
        target.defense_fails(self)
        target.hurt(self.wound_type)
      else
        self.attack_fails(target)
        target.defense_succeeds(self)
      end
      target.counter_attack(self)
    end
  end

  def wound_type
    return :wound
  end

  def counter_attack(target)
    if(rand(1..100) <= self.counter_success_chance && !self.dead?)
      self.counter_happens(target)
      target.counter_defense_happens(self)
      if(rand(1..100) <= self.attack_success_chance)
        self.counter_succeeds(target)
        target.counter_defense_fails(self)
        target.hurt(self.wound_type)
      else
        self.counter_fails(target)
        target.counter_defense_succeeds(self)
      end
    end
  end

  def attackable?
    !self.dead?
  end

  def butcherable?
    self.dead?
  end
  def max_health
    self.body.max_health
  end

  # CALLBACKS, no behaviour unless overwritten
  def attack_happens(opponent) end
  def attack_succeeds(opponent) end
  def attack_fails(opponent) end
  def defense_happens(opponent) end
  def defense_succeeds(opponent) end
  def defense_fails(opponent) end
  def counter_happens(opponent) end
  def counter_succeeds(opponent) end
  def counter_fails(opponent) end
  def counter_defense_happens(opponent) end
  def counter_defense_succeeds(opponent) end
  def counter_defense_fails(opponent) end

  # DELEGATES
  delegate :die, :to => :body
  delegate :dead?, :to => :body
  delegate :change_health, :to => :body
  delegate :set_health, :to => :body
  delegate :health, :to => :body
  delegate :max_health, :to => :body
  delegate :check_for_death, :to => :body
  delegate :health_fraction, :to => :body
  delegate :damage_fraction, :to => :body
  delegate :wounds, :to => :body
  delegate :confirm_death, :to => :body
  delegate :hurt, :to => :body
end
