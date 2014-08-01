class CharacterPossession < ActiveRecord::Base
  belongs_to :character
  validates_presence_of :character_id
  validates_presence_of :possession_id

  def possession
    Possession.find(self.possession_id)
  end
end
