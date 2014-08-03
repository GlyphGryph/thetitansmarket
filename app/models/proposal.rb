class Proposal < ActiveRecord::Base
  belongs_to :sender, :class_name=>"Character"
  belongs_to :receiver, :class_name=>"Character"
  belongs_to :content, :polymorphic=>true
  validates_presence_of :sender_id
  validates_presence_of :receiver_id
  validates_presence_of :status
end
