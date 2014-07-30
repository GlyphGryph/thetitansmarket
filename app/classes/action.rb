class Action
  @@actions = {}
  class << self
    def all
      @@actions.values
    end

    def find(id)
      @@actions[id]
    end
  end

  attr_reader :id, :name, :description, :function

  def initialize(id, params={})
    @id = id
    @name = params[:name] || "Name Error"
    @description = params[:description] || "Description Error"
    @function = params[:function] || lambda { return "Function error." }
    @@actions[@id]=self
  end
end

Action.new("rest", 
  { :name=>"Rest", 
    :description=>"You relax.", 
    :function => lambda { return "Zzzzzz... You rest a while." }
  }
)

Action.new("reminisce", 
  { :name=>"Reminisce", 
    :description=>"You think about the past.", 
    :function => lambda { return "Sigh... You reminisce a while." }
  }
)

Action.new("explore", 
  { :name=>"Explore", 
    :description=>"You explore the wilds.", 
    :function => lambda { return "Tallyho! You explore a while." }
  }
)
