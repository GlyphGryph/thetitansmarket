class TradeAskedCharacterKnowledge < ActiveRecord::Base
  belongs_to :trade
  belongs_to :character_knowledge
end
