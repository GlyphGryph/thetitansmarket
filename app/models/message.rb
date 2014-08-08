class Message < ActiveRecord::Base
  has_one :proposal, :as => :content
  has_one :sender, :through => :proposal, :class_name => "Character"
  has_one :receiver, :through => :proposal, :class_name => "Character"
  validates_presence_of :body
  serialize :body
  before_create :default_attributes

  def acceptable?
    false
  end

  def name_for_sender
    return "A message for "+self.receiver.name
  end

  def name_for_receiver
    return "A message from "+self.sender.name
  end

  def text_for(viewer)
    text = ""
    self.body.each do |element|
      if(element['type'] == 'gesture')
        text += "<div class='gesture'>"
        text += Gesture.find(element['gesture_id']).result.call(viewer, sender, Character.find(element['target_id']))
        text += "</div>"
      elsif(element['type'] == 'text')
        text += "<div class='text'>"
        text += element['value']
        text += "</div>"
      end
    end
    return text
  end
  
  def add_text(text)
    self.body << {'type' => 'text', 'value' => text}
  end

  def add_gesture(gesture, target)
    self.body ||= []
    self.body << {'type' => 'gesture', 'gesture_id' => gesture.id, 'target_id' => target.id}
  end

private
  def default_attributes
    self.body ||= []
  end
end
