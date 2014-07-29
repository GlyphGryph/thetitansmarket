class World < ActiveRecord::Base
  has_many :characters, :dependent => :destroy
  before_save :name_world
  
  NOUN_TARGETS = %w{ Apples Answers Ale Berries Books Barter Carts Cattle Dogs Envy Fear Faces Frogs Farmers 
                    Grain Greed Gold Happiness Hate Jokes Lies Laws Merchants Needs Needles Oranges 
                    Shinies Selling Wheat Work Labours Wealth Poverty }
  MARKET_SYNONYMS = %w{ Market Bazaar Faire Emporium }

  def name_world
    unless(self.name) 
      # If no name is provided, build one
      self.name = NOUN_TARGETS.sample+" & "+NOUN_TARGETS.sample+" "+MARKET_SYNONYMS.sample
    end
  end

  def join(user)
    new_character = Character.new(:user => user, :world => self)
    new_character.save
    new_character
  end
end
