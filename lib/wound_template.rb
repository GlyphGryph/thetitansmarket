class WoundTemplate
  extend CollectionTracker
  extend DataLoader

  attr_reader :id, :name, :description

  def initialize(params={})
    (@id = params[:id]) || raise "No id provided for WoundTemplate"
    @name = params[:name] || "Name Error"
    @description = params[:description] || "Description Error"
  end

  def decays_to(owner, recovery_value)
    wound_replacement = nil
    return wound_replacement
  end
end

require_dependency "data/wound/all"
