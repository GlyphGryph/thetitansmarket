#####################
# These functions are for interfacing with a body. The owner must possess a body for them to work
#
# Having a body allows the owner to attack and be attacked, and to spend vigor on doing actions
# It also tracks whether the owner is dead, and allows the owner to be butchered if so
# 
# The methods you are likely to want to overwrite when including this are:
# check_for_death - this determines whether or not the body should be killed
# confirm_death - this is run when a body dies and runs any needed cleanup code on the part of the owner
# starting_health - health and max health
# attacked - required for combat
# attacked_by - required for combat
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
  def counter_attack_chance
    return 50
  end
  def attacks_require_vigor
    false
  end

  def add_body
    self.body = Body.new(:max_health => self.starting_health)
    self.body.save!
  end

  def attacked_by(attacker, wound)
    self.hurt(1, attacker)
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
      if(rand(1..100) <= self.attack_success_chance)
        Message.send(self, 'important', "You launch an attack!")
        Message.send(target, 'important', "#{self.get_name} attacks you!")
        target.attacked_by(self, "TODO:THIS IS A WOUND")
      else
        Message.send(self, 'important', "You fumble your attack.")
        Message.send(target, 'important', "#{self.get_name} fumbles an attack!")
      end
      target.counter_attack(self)
    end
  end

  def counter_attack(target)
    if(rand(1..100) <= self.counter_attack_chance && !self.dead?)
      if(rand(1..100) <= self.attack_success_chance)
        Message.send(self, 'important', "You strike back!")
        Message.send(target, 'important', "#{self.get_name} strikes back!")
        target.attacked_by(self, "TODO:THIS IS A WOUND")
      else
        Message.send(self, 'important', "You fumble a counter attack.")
        Message.send(target, 'important', "#{self.get_name} tries to strike back, but fails!")
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
