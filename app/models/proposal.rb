class ProposalValidator < ActiveModel::Validator
  def validate(record)
    unless( ['new', 'open', 'accepted', 'declined', 'cancelled'].include?(record.status) )
      record.errors[:proposal] << " can not have a status of #{record.status}."
    end
  end
end


class Proposal < ActiveRecord::Base
  belongs_to :sender, :class_name=>"Character"
  belongs_to :receiver, :class_name=>"Character"
  belongs_to :content, :polymorphic=>true, :dependent => :destroy
  validates_presence_of :sender_id
  validates_presence_of :receiver_id
  validates_presence_of :status
  include ActiveModel::Validations
  validates_with ProposalValidator

  before_create :default_attributes

  def default_attributes
    self.status ||= "new"
  end
  
  def accept
    if(self.status == 'open' && self.content.acceptable?)
      success = self.content.accept
      if(success)
        self.status = 'accepted'
        self.save!
      end
      return success
    else
      self.errors[:proposal] << " is in the #{self.status} state, which is invalid for accepting."
      return false
    end
  end

  def decline
    if(self.status=="open" || self.status=="new")
      success = self.content.decline
      if(success)
        self.status = 'declined'
        self.save!
      end
      return success
    else
      self.errors[:proposal] << " is in the #{self.status} state, which is invalid for declining."
      return false
    end
  end

  def cancel
    if(self.status=="open" || self.status=="new")
      success = self.content.cancel
      if(success)
        self.status = 'cancelled'
        self.save!
      end
      return success
    else
      self.errors[:proposal] << " is in the #{self.status} state, which is invalid for cancelling."
      return false
    end
  end

  def mark_read
    if(self.status == 'new')
      self.status = 'open'
      self.save!
    end
  end

  def name_for_sender
    content.name_for_sender || "Unknown Proposal to #{self.receiver.name}"
  end

  def name_for_receiver
    content.name_for_receiver || "Unknown Proposal from #{self.sender.name}"
  end
end
