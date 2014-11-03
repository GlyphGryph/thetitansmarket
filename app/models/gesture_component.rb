class GestureComponent < ActiveRecord::Base
  belongs_to :message
  has_one :message_component, :as => :element

  def display_for(viewer)
    return "TEMP"
  end
end
