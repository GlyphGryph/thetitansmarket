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

  def add_body
    self.body = Body.new(:max_health => self.starting_health)
    self.body.save!
  end

  def attacked_by(attacker, wound)
    Message.send(self, 'important', "#{attacker.get_name} attacks you!")
    self.hurt(1, attacker)
  end

  def attack(target)
    if(target.dead?)
      Message.send(self, 'important', "You can't attack the dead.")
    elsif(!target.dead?)
      Message.send(self, 'important', "You launch an attack!")
      target.attacked_by(self, "TODO:THIS IS A WOUND")
      target.counter_attack(self)
    end
  end

  def counter_attack(target)
    if(rand(1..2) > 1)
      if(target.dead?) 
        Message.send(self, 'important', "You can't attack the dead.")
      else
        Message.send(self, 'important', "You strike back!")
        Message.send(target, 'important', "#{self.get_name} strikes back!")
        target.attacked_by(self, "TODO:THIS IS A WOUND")
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

  def hurt(amount, source=nil)
    Message.send(self, 'important', "You take #{amount} damage.")
    if(source)
      Message.send(source, 'important', "#{self.get_name} takes #{amount} damage.")
    end
    self.change_health(-amount)
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
end
