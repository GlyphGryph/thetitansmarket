class Wound < ActiveRecord::Base
  belongs_to :owner, :polymorphic=>true

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
end
