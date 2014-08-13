class World < ActiveRecord::Base
  has_many :characters, :dependent => :destroy
  has_many :world_explorations, :dependent => :destroy
  before_create :default_attributes
  after_create :default_relationships
  
  NOUN_TARGETS = %w{ Apples Answers Ale Berries Books Barter Carts Cattle Dogs Envy Fear Faces Frogs Farmers 
                    Grain Greed Gold Happiness Hate Jokes Lies Laws Merchants Needs Needles Oranges 
                    Shinies Selling Wheat Work Labours Wealth Poverty }
  MARKET_SYNONYMS = %w{ Market Bazaar Faire Emporium }

  def generate_name
    unless(self.name) 
      # If no name is provided, build one
      self.name = NOUN_TARGETS.sample+" & "+NOUN_TARGETS.sample+" "+MARKET_SYNONYMS.sample
    end
  end

  def default_attributes
    self.name ||= generate_name
    self.turn ||= 1
    self.last_turned ||= DateTime.now
  end

  def default_relationships
    self.build_exploration_pool
  end

  def build_exploration_pool
    50.times do
      self.world_explorations << WorldExploration.new(:world => self, :exploration_id => 'wildlands_claim')
    end
    10.times do
      self.world_explorations << WorldExploration.new(:world => self, :exploration_id => 'dolait_claim')
    end
    10.times do
      self.world_explorations << WorldExploration.new(:world => self, :exploration_id => 'wampoon_claim')
    end
    10.times do
      self.world_explorations << WorldExploration.new(:world => self, :exploration_id => 'tomatunk_claim')
    end
    10.times do
      self.world_explorations << WorldExploration.new(:world => self, :exploration_id => 'animal_attack')
    end
    10.times do
      self.world_explorations << WorldExploration.new(:world => self, :exploration_id => 'nothing')
    end
    5.times do
      self.world_explorations << WorldExploration.new(:world => self, :exploration_id => 'artifact')
    end
  end

  def explore_with(character)
    world_exploration = self.world_explorations.sample
    if(!world_exploration)
      throw "Error: Ran out of explorations on world #{self.id}: #{self.name}"
    end

    # Chances of failure will stay in the pool forever
    if(world_exploration.exploration_id == 'nothing')
      return world_exploration.get.result(character)
    else
      # Other explorations, however, can only be executed once
      result = world_exploration.get.result(character)
      world_exploration.destroy!
      return result
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
  
  def turn_timed_out?
    return self.until_time_out <= 0
  end

  def until_time_out
    return (24.hour - (Time.now - self.last_turned))
  end
  
  def ready_to_execute?
    return self.unready_characters.empty? || self.turn_timed_out?
  end

  def execute
    if(self.ready_to_execute?)
      begin
        ActiveRecord::Base.transaction do
          self.characters.each do |character|
            character.execute
          end
          self.turn += 1
          self.last_turned = Time.now
          self.save!
        end
      rescue => e
        raise e
      end
      return true
    else
      return false
    end
  end
end
