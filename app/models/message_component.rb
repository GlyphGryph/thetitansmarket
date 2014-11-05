class MessageComponent < ActiveRecord::Base
  belongs_to :message
  belongs_to :element, :polymorphic => true, :dependent => :destroy

  def display_for(viewer)
    element.display_for(viewer)
  end
  
  def self.build(sender, type, value, target)
    component = nil
    ActiveRecord::Base.transaction do
      component = self.new()
      if(type=="speech")
        component.element = SpeechComponent.build(sender, value)
      elsif(type=="gesture")
        component.element = GestureComponent.build(sender, value, target)
      else
        raise "Invalid message component type"
      end
      component.save!
    end
    raise "Failed to create message component." unless component
    return component
  end
end
