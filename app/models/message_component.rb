class MessageComponent < ActiveRecord::Base
  belongs_to :message
  belongs_to :element, :polymorphic => true, :dependent => :destroy

  def display_for(viewer)
    element.body(viewer)
  end
end
