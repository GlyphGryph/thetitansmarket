class Body < ActiveRecord::Base
  belongs_to :owner, :polymorphic=>true
  belongs_to :world

  before_create :default_attributes
  after_create :default_relationships

  def default_attributes
    self.max_health ||= 1
    self.health ||= self.max_health
  end
  
  def default_relationships
    self.world ||= self.owner.world
    self.save!
  end

  def dead?
    return self.dead
  end

  def die
    if self.dead?
      return false
    end
    self.dead = true
    self.world.broadcast('important', "#{self.owner.name} has died.", :exceptions => [self.owner])
    if(self.owner.respond_to?(:record))
      self.owner.record("important", "You have died.")
    end
    self.save!
    return true
  end

  def change_health(amount)
    self.health += amount
    if(self.health > self.max_health)
      self.health = self.max_health
    end
    self.owner.check_for_death
    self.save!
  end

  def set_health(amount)
    self.health = amount
    self.owner.check_for_death
    self.save!
  end

  def check_for_death
    if(self.dead?)
      return true
    elsif(self.health < 0)
      self.owner.die
      return true
    end
  end

  def hurt(amount)
    self.world.broadcast('important', "#{self.owner.name} takes #{amount} damage.", :exceptions => [self.owner])
    if(self.owner.respond_to?(:record))
      self.owner.record("important", "You have taken #{amount} damage.")
    end
    self.owner.change_health(-amount)
  end

  def health_fraction
    if(max_health > 0)
      return self.health.to_f / self.max_health.to_f
    else
      return 0
    end
  end

  def damage_fraction
    return 1.0 - self.health_fraction.to_f
  end
end
