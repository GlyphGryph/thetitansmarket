class MessageComponent < ActiveRecord::Base
  belongs_to :message
  
  def speech?
    return is_speech
  end

  def gesture?
    return !is_speech
  end
end
