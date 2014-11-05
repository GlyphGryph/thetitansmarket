class SpeechComponent < ActiveRecord::Base
  belongs_to :message
  belongs_to :actor, :class_name => 'Character'
  has_one :message_component, :as => :element

  def display_for(viewer)
    if(viewer == self.actor)
      return "You say: #{self.quote}"
    else
      return "#{self.actor.get_name} says: #{self.quote}"
    end
  end

  def self.build(actor, quote)
    raise "actor cannot be nil" unless actor
    component = nil
    ActiveRecord::Base.transaction do
      component = self.new(:actor => actor, :quote => quote)
      component.save!
    end
    raise "Failed to create message component." unless component
    return component
  end
end
