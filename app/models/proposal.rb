class ProposalValidator < ActiveModel::Validator
  def validate(record)
    unless( ['open', 'accepted', 'declined', 'cancelled'].include?(record.status) )
      record.errors[:proposal] << " can not have a status of #{record.status}."
    end
    unless( record.sender.world == record.receiver.world )
      record.errors[:proposal] << "Proposals can't cross the barriers between worlds."
    end
  end
end


class Proposal < ActiveRecord::Base
  belongs_to :sender, :class_name=>"Character"
  belongs_to :receiver, :class_name=>"Character"
  belongs_to :content, :polymorphic=>true, :dependent => :destroy
  has_one :world, :through => :sender
  validates_presence_of :sender_id
  validates_presence_of :receiver_id
  include ActiveModel::Validations
  validates_with ProposalValidator

  before_validation :default_attributes, :on => :create

  def default_attributes
    self.status ||= "open"
    self.viewed_by_sender ||= true
    self.viewed_by_receiver ||= false
    self.turn ||= self.world.turn
  end
  
  def acceptable?
    return content.acceptable?
  end

  def accept
    if(self.status == 'open' && self.content.acceptable?)
      success = self.content.accept
      if(success)
        self.status = 'accepted'
        self.viewed_by_sender = false
        self.save!
      else
        self.status = 'declined'
        self.viewed_by_sender = false
        self.save!
      end
      return success
    else
      self.errors[:proposal] << " is in the #{self.status} state, which is invalid for accepting, or you can't accept this type of proposal."
      return false
    end
  end

  def decline
    if(self.status=="open" && self.content.acceptable?)
      success = self.content.decline
      if(success)
        self.status = 'declined'
        self.viewed_by_sender = false
        self.save!
      end
      return success
    else
      self.errors[:proposal] << " is in the #{self.status} state, which is invalid for declining, or you can't decline this type of proposal."
      return false
    end
  end

  def cancel
    if(self.status=="open" && self.content.acceptable?)
      success = self.content.cancel
      if(success)
        self.status = 'cancelled'
        self.viewed_by_receiver = false
        self.save!
      end
      return success
    else
      self.errors[:proposal] << " is in the #{self.status} state, which is invalid for cancelling, or you can't cancel this type of proposal."
      return false
    end
  end

  def mark_read_for(character)
    if(self.sender == character && !self.viewed_by?(character))
      self.viewed_by_sender = true
      self.save!
    elsif(self.receiver == character && !self.viewed_by?(character))
      self.viewed_by_receiver = true
      self.save!
    end
  end

  def viewed_by?(character)
    if(self.sender == character)
      return self.viewed_by_sender
    elsif(self.receiver == character)
      return self.viewed_by_receiver
    end   
  end

  def name_for_sender
    content.name_for_sender || "Unknown Proposal to #{self.receiver.name}"
  end

  def name_for_receiver
    content.name_for_receiver || "Unknown Proposal from #{self.sender.name}"
  end

  def self.build(type, sender, receiver, components)
    proposal = nil
    ActiveRecord::Base.transaction do
      proposal = self.new(:sender => sender, :receiver => receiver)
      if(type == :message)
        proposal.content = Message.build(sender, components)
      else
        raise "Invalid proposal type '#{type.inspect}'"
      end
      proposal.save!
    end
    raise "Failed to create proposal." unless proposal
    return proposal
  end
end
