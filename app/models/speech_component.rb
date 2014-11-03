class SpeechComponent < ActiveRecord::Base
  belongs_to :message
  has_one :message_component, :as => :element

  def display_for(viewer)
    return self.quote
  end
end
