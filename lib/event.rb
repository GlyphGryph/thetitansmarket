class Event
  extend CollectionTracker
  attr_reader :id, :description, :tickets

  def initialize(id, params={})
    @id = id
    @description = params[:description] || "Description Error"
    @silent = params[:silent] || false
    @tickets = params[:tickets] || 0
    creates = params[:creates] || {}
    @situations = []
    @occurences = []
    if(creates[:situation])
      @situations << creates[:situation]
    end
    if(creates[:occurence])
      
      @occurences << Occurence.new(creates[:occurence])
    end
    self.class.add(@id, self)
  end

  # Randomly select an available event
  def self.draw(world)
    tickets = []
    self.all.each do |event|
      event.tickets.times do
        tickets << event
      end
    end
    return tickets.sample
  end

  def silent?
    return @silent
  end

  def execute(world)
    if(!self.silent?)
      world.broadcast("event", self.description)
    end
    if(@situations)
      @situations.each do |situation|
        world.world_situations << WorldSituation.new(:situation_id => situation[:id], :duration => situation[:duration])
      end
    end
    if(@occurences)
      @occurences.each do |occurence|
        occurence.execute(world)
      end
    end
  end
end

class Occurence
  def initialize(params={})
    @characters = params[:characters] || :all
    outcome_definitions = params[:outcomes] || []
    @outcomes = []
    outcome_definitions.each do |outcome_definition|
      new_outcome = OccurenceOutcome.new(outcome_definition)
      new_outcome.tickets.times do
        @outcomes << new_outcome
      end
    end
  end

  def execute(world)
    if(@characters == :all)
      # Do to all characters
      target_characters = world.characters
    else
      # Or do to a given number of characters
      target_characters = world.characters.sample(@characters)
    end
    target_characters.each do |character|
      @outcomes.sample.execute(character)
    end
  end
end

class OccurenceOutcome
  attr_reader :tickets

  def initialize(params={})
    @tickets = params[:tickets] || 1
    @result = params[:result] || lambda { |character| return false }
  end

  def execute(character)
    @result.call(character)
  end
end

# Load data
require_dependency "data/event/all"
