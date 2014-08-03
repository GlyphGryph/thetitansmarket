class Trade < ActiveRecord::Base
  has_many :trade_asked_character_possessions
  has_many :trade_offered_character_possessions
  has_many :asked_character_possessions, :through => :trade_asked_character_possessions, :source => :character_possession
  has_many :offered_character_possessions, :through => :trade_offered_character_possessions, :source => :character_possession
end
