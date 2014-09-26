class TradePossession < ActiveRecord::Base
  belongs_to :trade
  belongs_to :possession_variant
  validates_presence_of :trade, :quantity, :possession_id, :possession_variant_id
  validates :offered, :inclusion => {:in => [true, false]}

  def self.asked
    where(:offered => false)
  end

  def self.offered
    where(:offered => true)
  end

  def offered?
    self.offered
  end

  def get
    element = Possession.find(self.possession_id)
    unless(element)
      raise "Could not find possession for TradePossession #{self.id} with item type '#{self.possession_id}' for trade #{self.trade_id}"
    end
    return element
  end

  def get_name(type=:singular)
    if(type==:plural)
      return self.possession_variant.plural_name
    else
      return self.possession_variant.singular_name
    end
  end
end

