class Body < ActiveRecord::Base
  belongs_to :owner, :polymorphic=>true
  belongs_to :world

  before_create :default_attributes
  after_create :default_relationships

  def default_attributes
    self.max_health ||= 1
    self.health ||= self.max_health
    if(self.owner)
      self.name ||= "Body of "+owner.get_name
    else
      self.name ||= "Generic Corpse"
    end
  end
  
  def default_relationships
    self.world ||= self.owner.world
    self.save!
  end

  def dead?
    return self.dead
  end

  def die
    if(self.owner)
      if self.dead?
        return false
      end
      self.dead = true
      self.world.broadcast('important', "#{self.owner.get_name} has died.", :exceptions => [self.owner])
      if(self.owner.respond_to?(:record))
        self.owner.record("important", "You have died.")
      end
      self.save!
      self.owner.confirm_death
      return true
    end
  end

  # Health cannot go above max
  def change_health(amount)
    self.health += amount
    if(self.health > self.max_health)
      self.health = self.max_health
    end
    self.owner.check_for_death
    self.save!
  end

  # Setting the health changes the max if its higher
  def set_health(amount)
    self.health = amount
    if(self.health > self.max_health)
      self.max_health = self.health
    end
    self.owner.check_for_death
    self.save!
  end

  def check_for_death
    if(self.dead?)
      return true
    elsif(self.health <= 0)
      self.owner.die
      return true
    end
    return false
  end

  def hurt(amount)
    self.world.broadcast('important', "#{self.owner.get_name} takes #{amount} damage.", :exceptions => [self.owner])
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
