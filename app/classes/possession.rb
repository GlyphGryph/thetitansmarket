class Possession
  @entries = {}
  class << self
    def all
      @entries.values
    end

    def find(id)
      @actions[id]
    end

    def add(id, value)
      @entries[id]=value
    end
  end

  attr_reader :id, :name, :description, :result, :cost

  def initialize(id, params={})
    @id = id
    @name = params[:name] || "Name Error"
    @description = params[:description] || "Description Error"
    self.class.add(@id, self)
  end
end

# Format for new items
# 'id', {:name => 'Name', :description=>"Multi-word description." }

Possession.new("generic_object", 
  { :name=>"Perfectly Generic Object", 
    :description=>"The only notable thing about this object is its complete lack of notable features.", 
  }
)
