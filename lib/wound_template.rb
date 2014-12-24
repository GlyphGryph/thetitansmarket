class WoundTemplate
  extend CollectionTracker
  extend DataLoader

  attr_reader :id, :name, :description, :damage

  def initialize(params={})
    @id = params[:id]
    @name = params[:name] || "Name Error"
    @description = params[:description] || "Description Error"
    @damage = params[:damage] || 0
  end

  def decays_to(owner, recovery_value)
    wound_replacement = nil
    return wound_replacement
  end
end

require_dependency "data/wound/all"
