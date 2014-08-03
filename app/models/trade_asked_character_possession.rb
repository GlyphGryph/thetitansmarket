class TradeAskedCharacterPossession < ActiveRecord::Base
  belongs_to :trade
  belongs_to :character_possession
end
