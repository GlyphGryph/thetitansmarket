class Event
  extend CollectionTracker
  attr_reader :id, :description, :silent, :tickets

  def initialize(id, params={})
    @id = id
    @description = params[:description] || "Description Error"
    @silent = params[:silent] || false
    @tickets = params[:tickets] || 0
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
end 

# Load data
require_dependency "data/event/all"
