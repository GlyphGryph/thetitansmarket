class Trade < ActiveRecord::Base
  has_one :proposal, :as => :content

  has_many :trade_asked_character_possessions, :dependent => :destroy
  has_many :trade_offered_character_possessions, :dependent => :destroy
  has_many :asked_character_possessions, :through => :trade_asked_character_possessions, :source => :character_possession
  has_many :offered_character_possessions, :through => :trade_offered_character_possessions, :source => :character_possession

  has_many :trade_asked_character_knowledges, :dependent => :destroy
  has_many :trade_offered_character_knowledges, :dependent => :destroy

  has_one :sender, :through => :proposal, :class_name => "Character"
  has_one :receiver, :through => :proposal, :class_name => "Character"

  def acceptable?
    return true
  end

  def accept
    # The possessions offered are the ones we gain, the proffessions asked are the ones we lose
    asked = self.asked_character_possessions
    offered = self.offered_character_possessions
    sender_message = ["You traded with #{receiver.name}."]
    receiver_message = ["You traded with #{sender.name}."]
    success = true
    # We want to do this as a transaction - if there's an error changing any of these, we want to roll them all back
    begin
      ActiveRecord::Base.transaction do
        sender = proposal.sender
        receiver = proposal.receiver
        asked.each do |character_possession|
          # Make sure this is still owned by the right person
          if(character_possession && character_possession.character == receiver)
            character_possession.character = sender
            possession_name = character_possession.get.name
            sender_message << ["You gained a #{possession_name}."]
            receiver_message << ["You lost your #{possession_name}."]
            character_possession.save!
          else
            sender_message << ["You failed to trade with #{receiver.name}. #{receiver.name} no longer possess one of the objects being asked for."]
            receiver_message << ["You failed to trade with #{sender.name}. You no longer possess one of the objects being asked for."]
            raise "The character no longer possesses this item."
          end
        end
        offered.each do |character_possession|
          if(character_possession.character == sender)
            character_possession.character = receiver
            possession_name = character_possession.get.name
            sender_message << ["You lost your #{possession_name}."]
            receiver_message << ["You gained a #{possession_name}."]
            character_possession.save!
          else
            sender_message << ["You failed to trade with #{receiver.name}. You no longer possess one of the objects being offered."]
            receiver_message << ["You failed to trade with #{sender.name}. #{sender.name} no longer possess one of the objects being offered."]
            raise "The character no longer possesses this item."
          end
        end
      end
    rescue
      success = false
    end
    sender.recent_history << sender_message.join(" ")
    sender.save!
    receiver.recent_history << receiver_message.join(" ")
    receiver.save!
    return success
  end

  def decline
    return true
  end

  def cancel
    return true
  end

  def name_for_sender
    if(self.trade_asked_character_possessions.empty? && self.trade_offered_character_possessions.empty?)
      return "Nihilist Exchange with "+self.receiver.name
    elsif(self.trade_asked_character_possessions.empty?)
      return "Tribute Offer to "+self.receiver.name
    elsif(self.trade_offered_character_possessions.empty?)
      return "Tribute Request to "+self.receiver.name
    else
      return "Trade Offer to "+self.receiver.name
    end
  end

  def name_for_receiver
    if(self.trade_asked_character_possessions.empty? && self.trade_offered_character_possessions.empty?)
      return "Nihilist Exchange with "+self.sender.name
    elsif(self.trade_asked_character_possessions.empty?)
      return "Tribute Offer from "+self.sender.name
    elsif(self.trade_offered_character_possessions.empty?)
      return "Tribute Request from "+self.sender.name
    else
      return "Trade Offer from "+self.sender.name
    end
  end
end
