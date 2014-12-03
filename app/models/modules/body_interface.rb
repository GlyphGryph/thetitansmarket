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
    end
  end

  def attacked_by(attacker)
    raise "Attacked by not implemented for #{self.class}"
  end

  def attack(target)
    raise "Attack not implemented for #{self.class}"
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

  def health
    self.body.health
  end

  def max_health
    self.body.max_health
  end

  def hurt(amount)
    self.change_health(-amount)
  end

  def check_for_death
    self.body.check_for_death
  end

  def health_fraction
    self.body.health_fraction
  end

  def damage_fraction
    self.body.damage_fraction
  end
end
