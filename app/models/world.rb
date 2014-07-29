class World < ActiveRecord::Base
  has_many :characters, :dependent => :destroy
  before_create :name_world
  
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
    return new_character
  end

  def unready_characters
    return self.characters.select{|character| !character.ready? }
  end
  
  def ready_to_execute?
    return self.unready_characters.empty?
  end

  def execute
    if(self.ready_to_execute?)
      self.characters.each do |character|
        character.unready
        character.character_actions.destroy_all
      end
      return true
    else
      return false
    end
  end
end
