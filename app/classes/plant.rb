class Plant
  extend CollectionTracker
  attr_reader :id, :plant_name, :food_name, :seed_name

  def initialize(id, params={})
    @id = id
    @plant_name = params[:plant_name] || "ERROR: UNKNOWN"
    @food_name = params[:food_name] || "ERROR: UNKNOWN"
    @seed_name = params[:seed_name] || "ERROR: UNKNOWN"
    self.class.add(@id, self)
  end
end

Plant.new("strawberry",
  { :plant_name=>"Strawberry Bush",
    :seed_name=>"Srawberry Seeds",
    :food_name=>"Strawberries",
  }
)
Plant.new("blueberry",
  { :plant_name=>"Blueberry Bush",
    :seed_name=>"Blueberry Seeds",
    :food_name=>"Blueberries",
  }
)
Plant.new("blackberry",
  { :plant_name=>"Blackberry Bush",
    :seed_name=>"Blackberry Seeds",
    :food_name=>"Blackberries",
  }
)
