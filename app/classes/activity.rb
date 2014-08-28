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
    if(@offer_cost <= character.ap && @accept_cost <= target.ap)
      character.change_ap(-@offer_cost)
      target.change_ap(-@accept_cost)
      if(@result.call(character, target))
        character.recent_history  << @messages[:success].call([target.name])
        character.save!
        target.recent_history  << @messages[:success].call([character.name])
        target.save!
        return true
      end
    end
    message = "Attempted to #{self.name}."
    if(@offer_cost > character.ap)
      message += " #{character.name} did not have enough ap to complete the action."
    end
    if(@accept_cost > target.ap)
      message += " #{target.name} did not have enough ap to complete the action. "
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

# Format for new activitys
# 'id', {:name => 'Name', :description=>"Multi-word description.", 
# :result => lambda {|character, character_activity| return "Some string based on what happens, possibly conditional on character state" }, // Takes a character, returns a string
# :cost => lambda {|character| if(character.loves_chicken) return 5; else return 6;} // Takes a character, returns a digit
# }

Activity.new("play",
  { :name=>"Play", 
    :description=>"Play around with another character, increasing your happiness a bit. Costs 2 ap, grants 1 happy.", 
    :result => lambda { |character, target|
      character.change_happy(1)
      character.save!
      target.change_happy(1)
      target.save!
      return true
    },
    :messages => {
      :success => lambda { |args| "You play with #{args[0]} for a while, and the world doesn't seem to rest nearly so heavily on your shoulders for a while." },
    },
    :cost => {
      :accept => 2,
      :offer => 2,
    },
    :available => lambda { |character|
      return character.knows?("play")
    },
  }
)
