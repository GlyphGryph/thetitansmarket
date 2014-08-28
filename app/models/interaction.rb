class Interaction < ActiveRecord::Base
  has_one :proposal, :as => :content
  has_one :sender, :through => :proposal, :class_name => "Character"
  has_one :receiver, :through => :proposal, :class_name => "Character"
  validates_presence_of :activity_id

  def acceptable?
    true
  end

  def accept
    return Activity.find(self.activity_id).result(sender, receiver)
  end

  def decline
    return true
  end

  def cancel
    return true
  end

  def name
    return Activity.find(self.activity_id).name
  end

  def name_for_sender
    return "Request to #{Activity.find(self.activity_id).name} with  "+self.receiver.name
  end

  def name_for_receiver
    return "Request to  #{Activity.find(self.activity_id).name} from "+self.sender.name
  end
end
