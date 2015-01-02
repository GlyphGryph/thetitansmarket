class SeasonTemplate
  extend CollectionTracker
  extend DataLoader

  attr_reader :id, :name, :description, :style

  def initialize(params={})
    @id = params[:id]
    @name = params[:name] || "Name Error"
    @description = params[:description] || "Unkown Description"
    @to = params[:to] || :grey
    @style = params[:style] || "unseasoned"
  end

  def next
    return SeasonTemplate.find(@to) || SeasonTemplate.find(:grey)
  end

  def get
    return self
  end

  def get_name
    return self.name
  end
end

require_dependency "data/season/all"
