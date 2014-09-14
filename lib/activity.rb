class Activity
  extend CollectionTracker
  attr_reader :id, :name, :description, :cost, :available, :target_prompt, :requires_target

  def initialize(id, params={})
    @id = id
    @name = params[:name] || "Name Error"
    @description = params[:description] || "Description Error"
    @available = params[:available] || lambda { |character| return true }
    @result = params[:result] || lambda { |character, target| return "Function error." }
    @cost = params[:cost] || {}
    @accept_cost = @cost[:accept] || 0
    @offer_cost = @cost[:offer] || 0
    @messages = params[:messages] || {}
    self.class.add(@id, self)
  end

  def available?(character)
    return @available.call(character)
  end

  def result(character, target)
    # If one of the players can't play the cost, skip this and return false with an appropriate message
    # Otherwise execute the proposal assign an appropriate success message
    if(@offer_cost <= character.vigor && @accept_cost <= target.vigor)
      character.change_vigor(-@offer_cost)
      target.change_vigor(-@accept_cost)
      if(@result.call(character, target))
        character.recent_history  << @messages[:success].call([target.name])
        character.save!
        target.recent_history  << @messages[:success].call([character.name])
        target.save!
        return true
      end
    end
    message = "Attempted to #{self.name}."
    if(@offer_cost > character.vigor)
      message += " #{character.name} did not have enough vigor to complete the action."
    end
    if(@accept_cost > target.vigor)
      message += " #{target.name} did not have enough vigor to complete the action. "
    end
    character.recent_history  << message
    character.save!
    target.recent_history  << message
    target.save!
    return false
  end

  def type
    return "activity"
  end
end

# Load data
require_dependency "data/activity/all"

