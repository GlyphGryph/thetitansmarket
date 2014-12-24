class Wound < ActiveRecord::Base
  belongs_to :owner, :polymorphic=>true
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

  def apply_damage
    Message.send(self.owner.owner, 'important', "You take #{self.get.damage} damage.")
    owner.owner.world.broadcast('important', "#{self.owner.owner.get_name} takes #{self.get.damage} damage.", :exceptions => [self.owner.owner])
    self.owner.owner.change_health(-self.get.damage)
  end
end
