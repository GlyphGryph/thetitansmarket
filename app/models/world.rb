class World < ActiveRecord::Base
  has_many :characters
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
end
