class Trade < ActiveRecord::Base
  has_one :proposal, :as => :content
  has_many :trade_asked_character_possessions, :dependent => :destroy
  has_many :trade_offered_character_possessions, :dependent => :destroy
  has_many :asked_character_possessions, :through => :trade_asked_character_possessions, :source => :character_possession
  has_many :offered_character_possessions, :through => :trade_offered_character_possessions, :source => :character_possession

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
end
