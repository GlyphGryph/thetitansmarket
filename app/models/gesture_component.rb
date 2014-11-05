class GestureComponent < ActiveRecord::Base
  belongs_to :message
  belongs_to :actor, :class_name => 'Character'
  belongs_to :owner, :class_name => 'Character'
  has_one :message_component, :as => :element

  def display_for(viewer)
    gesture = Gesture.find(self.gesture_id)
    return gesture.result(viewer, self.actor, self.owner, self.owner_is_target, self.target_name)
  end

  def self.build(actor, gesture_id, target)
    raise "actor cannot be nil" unless actor
    component = nil
    ActiveRecord::Base.transaction do
      component = self.new(:gesture_id => gesture_id, :actor => actor)
      if(target)
        if(target[:type] == "character")
          component.owner_is_target = true
          target_character = Character.find(target[:id])
          component.owner = target_character
          component.target_name = target_character.get_name
        else  
          component.owner_is_target = false
          target_instance = Gesture.find_target(target[:type], target[:id])
          raise "Could not find target" unless target_instance
          component.owner = target_instance.character
          component.target_name = target_instance.get_name
        end
      else
        component.owner_is_target = true
        component.owner = actor
        component.target_name = actor.get_name
      end
      component.save!
    end
    raise "Failed to create message component." unless component
    return component
  end
end
