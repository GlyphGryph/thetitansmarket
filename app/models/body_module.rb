module BodyModule
  def attacked_by(character)
    raise "Attacked by not implemented for #{self.class}"
  end 

  def die
    if self.dead?
      return false
    end
    self.dead = true
    self.world.broadcast('event', "#{self.name} has died!")
  end

  def dead?
    return dead
  end
end
