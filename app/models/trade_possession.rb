class TradePossession < ActiveRecord::Base
  belongs_to :trade
  validates_presence_of :trade, :offered, :quantity, :possession_id, :possession_variant_id

  def self.asked
    where(:offered => false)
  end

  def self.offered
    where(:offered => true)
  end

  def get
    element = Possession.find(self.possession_id)
    unless(element)
      raise "Could not find possession for TradePossession #{self.id} with item type '#{self.possession_id}' for trade #{self.trade_id}"
    end
    return element
  end
end

