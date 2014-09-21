class PossessionVariant < ActiveRecord::Base
  validates_presence_of :key, :possession_id, :singular_name, :plural_name
  has_many :character_possessions
  has_many :trade_possessions

  def self.find_or_do(key, possession_id, singular_name, plural_name=nil)
    variant = PossessionVariant.find_by(:key => key, :possession_id => possession_id)
    if(variant.nil?)
      variant = PossessionVariant.new(:key => key, :possession_id => possession_id, :singular_name => singular_name, :plural_name => (plural_name || singular_name))
      variant.save!
    end
    return variant
  end

  def get
    element = Possession.find(self.possession_id)
    unless(element)
      raise "Could not find possession for TradePossession #{self.id} with item type '#{self.possession_id}' for trade #{self.trade_id}"
    end
    return element
  end
end

