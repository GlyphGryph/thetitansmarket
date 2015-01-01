class Wound < ActiveRecord::Base
  belongs_to :body
  after_create :apply_damage

  def get
    element = WoundTemplate.find(self.wound_template_id)
    unless(element)
      raise "Could not find template '#{self.wound_template_id}' for Wound #{self.id}"
    end
    return element
  end

  def get_name(type=:singular)
    return self.get.name
  end

  def owner
    self.body.owner
  end

  def apply_damage
    Message.send(self.owner, 'important', "You take #{self.get.damage} damage.")
    self.owner.world.broadcast('important', "#{self.owner.get_name} takes #{self.get.damage} damage.", :exceptions => [self.owner])
    self.owner.change_health(-self.get.damage)
  end

  def physical_hindrance
    return self.get.physical_hindrance
  end

  def mental_hindrance
    return self.get.mental_hindrance
  end

  def decay
    new_type = nil
    new_message = nil
    self.get.decay_targets.each do |target|
      if(target[:difficulty])
        roll = rand( self.owner.recovery_value..(WoundTemplate.max_difficulty+self.owner.recovery_value) )
        if(roll >= target[:difficulty])
          new_type = target[:id]
          new_message = target[:message]
          break
        end
      else
        new_type = target[:id]
        new_message = target[:message]
        break
      end
    end
    if(new_type)
      Wound.new(:body => self.body, :wound_template_id => new_type).save!
    end
    if(new_message)
      Message.send(self.owner, 'important', new_message)
    end
    self.destroy!
  end
end
