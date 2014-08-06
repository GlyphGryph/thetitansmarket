class Trade < ActiveRecord::Base
  has_one :proposal, :as => :content
  has_many :trade_asked_character_possessions, :dependent => :destroy
  has_many :trade_offered_character_possessions, :dependent => :destroy
  has_many :asked_character_possessions, :through => :trade_asked_character_possessions, :source => :character_possession
  has_many :offered_character_possessions, :through => :trade_offered_character_possessions, :source => :character_possession
  has_one :sender, :through => :proposal, :class_name => "Character"
  has_one :receiver, :through => :proposal, :class_name => "Character"

  def acceptable?
    return true
  end

  def accept
    # The possessions offered are the ones we gain, the proffessions asked are the ones we lose
    asked = self.asked_character_possessions
    offered = self.offered_character_possessions
    # We want to do this as a transaction - if there's an error changing any of these, we want to roll them all back
    ActiveRecord::Base.transaction do
      sender = proposal.sender
      receiver = proposal.receiver
      asked.each do |character_possession|
        # Make sure this is still owned by the right person
        if(character_possession.character == receiver)
          character_possession.character = sender
          character_possession.save!
        else
          raise "The character no longer possesses this item."
        end
      end
      offered.each do |character_possession|
        if(character_possession.character == sender)
          character_possession.character = receiver
          character_possession.save!
        else
          raise "The character no longer possesses this item."
        end
      end
    end
    return true
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
      return "Nihilist Exchange with "+self.receiver.name
    elsif(self.trade_asked_character_possessions.empty?)
      return "Tribute Offer from "+self.receiver.name
    elsif(self.trade_offered_character_possessions.empty?)
      return "Tribute Request from "+self.receiver.name
    else
      return "Trade Offer to "+self.receiver.name
    end
  end
end
