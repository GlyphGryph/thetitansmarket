class Message < ActiveRecord::Base
  has_one :proposal, :as => :content
  has_one :sender, :through => :proposal, :class_name => "Character"
  has_one :receiver, :through => :proposal, :class_name => "Character"
  has_many :message_components, :dependent => :destroy

  def acceptable?
    false
  end

  def name_for_sender
    return "A message for "+self.receiver.name
  end

  def name_for_receiver
    return "A message from "+self.sender.name
  end

  def display_for(viewer)
    message_components.each do 
      message.display_for(viewer)
    end
  end

  def self.build(sender, message_components)
    raise "sender cannot be nil" unless sender
    message = nil
    ActiveRecord::Base.transaction do
      message = self.new()
      # This turns the key/value pairs of index/value into a list of values sorted by index
      sorted_message_components = []
      message_components.each do |key, value|
        sorted_message_components[key.to_i] = value
      end
      sorted_message_components.compact!

      sorted_message_components.each do |component|
        message.message_components << MessageComponent.build(sender, component[:type], component[:value], component[:target])
      end
      message.save!
    end
    raise "Failed to create message." unless message.inspect
    return message
  end
end
