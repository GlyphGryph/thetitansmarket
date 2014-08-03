class CharacterPossession < ActiveRecord::Base
  belongs_to :character
  validates_presence_of :character_id
  validates_presence_of :possession_id
  attr_accessor :type, :contains

  def get
    Possession.find(self.possession_id)
  end
end
