class Visitor
  extend CollectionTracker
  attr_reader :id, :name, :description, :starting_health, :starting_anger, :starting_fear,
    :attack_success_chance, :counter_success_chance, :wound_type,
    :attack_happens, :attack_succeeds, :attack_fails,
    :defense_happens, :defense_succeeds, :defense_fails,
    :counter_happens, :counter_succeeds, :counter_fails,
    :counter_defense_happens, :counter_defense_succeeds, :counter_defense_fails

  def initialize(id, params={})
    @id = id
    @name = params[:name] || "Name Error"
    @description = params[:description] || "Description Error"
    @spawn = params[:spawn] || lambda { |instance| }
    @act = params[:act] || lambda { |instance| }

    @attacked = params[:attacked] || lambda { |instance, character| }
    @scared = params[:scared] || lambda { |instance, character| }
    @butchered = params[:butchered] || lambda { |instance, character| }
    @starting_health = params[:health]
    @starting_anger = params[:anger]
    @starting_fear = params[:fear]
    attack = params[:attack] || {}
    counter = attack[:counter] || {}
    defense = params[:defense] || {}
    counter_defense = defense[:counter] || {}
    @wound_type = params[:attack][:wound_type] || :error_wound
    @attack_success_chance = attack[:success_chance] || 100
    @counter_success_chance = counter[:success_chance] || 100

    # Callbacks
    @attack_happens = attack[:always] || lambda { |instance, target| }
    @attack_succeeds = attack[:success] || lambda { |instance, target| }
    @attack_fails = attack[:failure] || lambda { |instance, target| }
    @counter_happens = counter[:always] || lambda { |instance, target| }
    @counter_succeeds = counter[:success] || lambda { |instance, target| }
    @counter_fails = counter[:failure] || lambda { |instance, target| }

    @defense_happens =  defense[:always] || lambda { |instance, target| }
    @defense_succeeds = defense[:success] || lambda { |instance, target| }
    @defense_fails = defense[:failure] || lambda { |instance, target| }
    @counter_defense_happens = counter_defense[:always] || lambda { |instance, target| }
    @counter_defense_succeeds = counter_defense[:success] || lambda { |instance, target| }
    @counter_defense_fails = counter_defense[:failure] || lambda { |instance, target| }
    self.class.add(@id, self)
  end

  def execute(instance)
    @act.call(instance)
  end

  def spawn(instance)
    @spawn.call(instance)
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
