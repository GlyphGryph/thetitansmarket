class WoundTemplate
  extend CollectionTracker
  extend DataLoader

  attr_reader :id, :name, :description, :damage, :decay_targets

  def initialize(params={})
    @max_difficulty = 10
    @id = params[:id]
    @name = params[:name] || "Name Error"
    @description = params[:description] || "Description Error"
    @damage = params[:damage] || 0
    @decay_targets = params[:decay_targets]
  end

  def self.max_difficulty
    return 10
  end
end

require_dependency "data/wound/all"
