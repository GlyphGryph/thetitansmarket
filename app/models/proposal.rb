class Proposal < ActiveRecord::Base
  belongs_to :sender, :class_name=>"Character"
  belongs_to :receiver, :class_name=>"Character"
  belongs_to :content, :polymorphic=>true, :dependent => :destroy
  validates_presence_of :sender_id
  validates_presence_of :receiver_id
  validates_presence_of :status

  before_create :default_attributes

  def default_attributes
    self.status ||= "new"
  end

  def accept
    if(self.status == 'new' && self.content.acceptable?)
      success = self.content.accept
      if(success)
        self.status = 'accepted'
        self.save!
      end
      return success
    else
      return false
    end
  end

  def decline
    if(self.status == 'new')
      success = self.content.decline
      if(success)
        self.status = 'declined'
        self.save!
      end
      return success
    else
      return false
    end
  end

  def name_for_sender
    content.try(:name_for_sender) || "Unknown Proposal to #{self.receiver.name}"
  end

  def name_for_receiver
    content.try(:name_for_receiver) || "Unknown Proposal from #{self.sender.name}"
  end
end
