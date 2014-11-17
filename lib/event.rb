class Event
  extend CollectionTracker
  attr_reader :id, :description, :tickets

  def initialize(id, params={})
    @id = id
    @description = params[:description] || "Description Error"
    @silent = params[:silent] || false
    @tickets = params[:tickets] || 0
    @creates = params[:creates] || {}
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
    if(@creates[:situation])
      to_create = @creates[:situation]
      world.world_situations << WorldSituation.new(:situation_id => to_create[:id], :duration => to_create[:duration])
    end
    if(!self.silent?)
      world.broadcast("event", self.description)
    end
  end
end 

# Load data
require_dependency "data/event/all"
