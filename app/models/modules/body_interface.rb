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
    if(self.respond_to?(:record))
      self.record('important', "#{attacker.get_name} attacks you!")
    end
    self.hurt(1, attacker)
  end

  def attack(target)
    if(target.dead? && self.respond_to?(:record))
      self.record('important', "You can't attack the dead.")
    elsif(!target.dead?)
      if(self.respond_to?(:record))
        self.record('important', "You launch an attack!")
      end
      target.attacked_by(self, "TODO:THIS IS A WOUND")
      target.counter_attack(self)
    end
  end

  def counter_attack(target)
    if(rand(1..2) > 1)
      if(target.dead?) 
        if(self.respond_to?(:record))
          self.record('important', "You can't attack the dead.")
        end
      else
        if(self.respond_to?(:record))
          self.record('important', "You strike back!")
        end
        if(target.respond_to?(:record))
          target.record('important', "#{self.get_name} strikes back!")
        end
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

  def die
    self.body.die
  end

  def dead?
    self.body.dead?
  end

  def change_health(amount)
    self.body.change_health(amount)
  end

  def set_health(amount)
    self.body.set_health(amount)
  end

  def health
    self.body.health
  end

  def max_health
    self.body.max_health
  end

  def hurt(amount, source=nil)
    if(self.respond_to?(:record))
      self.record('important', "You take #{amount} damage.")
    end
    if(source && source.respond_to?(:record))
      source.record('important', "#{self.get_name} takes #{amount} damage.")
    end
    self.change_health(-amount)
  end

  def check_for_death
    self.body.check_for_death
  end

  def confirm_death
  end

  def health_fraction
    self.body.health_fraction
  end

  def damage_fraction
    self.body.damage_fraction
  end
end
