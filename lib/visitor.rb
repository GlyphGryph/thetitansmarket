class Visitor
  extend CollectionTracker
  attr_reader :id, :name, :description, :starting_health, :starting_anger, :starting_fear,
    :attack_success_chance, :attack_success_message, :attack_fail_message,
    :counter_success_chance, :counter_success_message, :counter_fail_message,
    :wound_type

  def initialize(id, params={})
    @id = id
    @name = params[:name] || "Name Error"
    @description = params[:description] || "Description Error"
    @result = params[:result] || lambda { |instance, character| return false}
    @attacked = params[:attacked] || lambda { |instance, character| return false}
    @scared = params[:scared] || lambda { |instance, character| return false}
    @butchered = params[:butchered] || lambda { |instance, character| return false}
    @starting_health = params[:health]
    @starting_anger = params[:anger]
    @starting_fear = params[:fear]
    @attack_success_chance = params[:attack][:success_chance] || 100
    @attack_success_message = params[:attack][:success_message] || "Error: Visitor unknown attack succeeded."
    @attack_fail_message = params[:attack][:fail_message] || "Error: Visitor unknown attack failed."
    @counter_success_chance = params[:counter][:success_chance] || 100
    @counter_success_message = params[:counter][:success_message] || "Error: Visitor unknown counter succeeded."
    @counter_fail_message = params[:counter][:fail_message] || "Error: Visitor unknown counter failed."
    @wound_type = params[:attack][:wound_type] || :error_wound
    self.class.add(@id, self)
  end

  def execute(character_condition)
    @result.call(character_condition)
  end

  def attacked(instance, character)
    @attacked.always.call(instance, character)
  end

  def scared(instance, character)
    @scared.call(instance, character)
  end

  def butchered(instance, character)
    @butchered.call(instance, character)
  end
end 

# Load data
require_dependency "data/visitor/all"
