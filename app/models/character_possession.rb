class CharacterPossession < ActiveRecord::Base
  belongs_to :character
  belongs_to :possession_variant
  has_many :trade_asked_character_possessions
  has_many :trade_offered_character_possessions
  has_one :world, :through => :character
  has_many :world_visitors, :as => :target
  validates_presence_of :character
  validates_presence_of :possession_id
  attr_accessor :type, :contains

  before_create :default_attributes

  def default_attributes
    self.possession_variant ||= PossessionVariant.find_or_do("standard", self.possession_id, self.get.name)
    self.charges ||= self.get.max_charges
  end

  def deplete(amount=1)
    self.charges -= amount
    if(charges < 0)
      self.charges += amount
      return false
    end
    self.save!
    return true
  end

  def charge(amount=1)
    self
  end

  def get
    element = Possession.find(self.possession_id)
    unless(element)
      raise "Could not find possession for CharacterPossession #{self.id} with item type '#{self.possession_id}' for character #{self.character_id}"
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
