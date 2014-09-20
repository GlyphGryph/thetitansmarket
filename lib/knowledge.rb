class Knowledge
  extend CollectionTracker
  attr_reader :id, :name, :description, :components, :sources, :consider, :research

  def initialize(id, params={})
    @id = id
    @name = params[:name] || "Name Error"
    @description = params[:description] || "Description Error"
    @learn_result = params[:learn_result] || lambda {|character, character_action| return true}
    @components = params[:components] || 1
    @sources = params[:sources] || {}
    @consider = params[:consider] || "No consideration text provided."
    @research = params[:research] || "No research text provided."
    self.class.add(@id, self)
  end

  def type
    return "knowledge"
  end

  def learn_result(character, character_action)
    return @learn_result.call(character, character_action)
  end
end

# Load data
require_dependency 'data/knowledge/all'
