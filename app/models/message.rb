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
end
