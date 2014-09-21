class CharacterPossession < ActiveRecord::Base
  belongs_to :character
  belongs_to :possession_variant
  has_many :trade_asked_character_possessions
  has_many :trade_offered_character_possessions
  validates_presence_of :character_id
  validates_presence_of :possession_id
  attr_accessor :type, :contains

  before_create :default_attributes

  def default_attributes
    self.possession_variant ||= PossessionVariant.find_or_do(key, self.possession_id, singular_name, plural_name)
  end

  def get
    element = Possession.find(self.possession_id)
    unless(element)
      raise "Could not find possession for CharacterPossession #{self.id} with item type '#{self.possession_id}' for character #{self.character_id}"
    end
    return element
  end
end
