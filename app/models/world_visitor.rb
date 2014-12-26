class WorldVisitor < ActiveRecord::Base
  include ConceptModule
  include BodyInterface

  belongs_to :world
  validates_presence_of :world_id
  validates_presence_of :visitor_id
  belongs_to :target, :polymorphic=>true

  before_create :default_attributes
  after_create :spawn

  def default_attributes
    self.anger = self.get.starting_anger
    self.fear = self.get.starting_fear
  end
  
  def starting_health
    self.get.starting_health
  end

  def spawn
    self.get.spawn(self)
  end

  def get
    element = Visitor.find(self.visitor_id)
    unless(element)
      raise "Could not find visitor for WorldVisitor with id #{self.id} looking for #{self.visitor_id}"
    end
    return element
  end

  def get_name(type=nil)
    return self.get.name
  end

  def execute
    if self.dead?
      return false
    end
    return self.get.execute(self)
  end

  def depart
    if self.dead?
      return false
    end
    self.destroy!
  end

  def scared_by(character)
    if self.dead?
      return false
    end
    self.get.scared(self, character)
  end

  def butchered_by(character)
    if self.dead?
      self.get.butchered(self, character)
      self.destroy!
      return true
    end
    return false
  end

  def change_fear(amount)
    self.fear+=amount
    if(self.fear < 0)
      self.fear=0
    end
    self.save!
  end

  def change_anger(amount)
    self.anger+=amount
    if(self.anger < 0)
      self.anger=0
    end
    self.save!
  end

  def change_target_to(new_target)
    self.target = new_target
    self.save!
  end

  def wound_type
    self.get.wound_type
  end
  def attack_success_chance
    self.get.attack_success_chance
  end
  def counter_attack_chance
    self.get.counter_success_chance
  end

  # Body interface callbacks
  def attack_happens(opponent)
    self.get.attack_happens.call(self, opponent)
  end
  def attack_succeeds(opponent)
    self.get.attack_succeeds.call(self, opponent)
  end
  def attack_fails(opponent)
    self.get.attack_fails.call(self, opponent)
  end
  def defense_happens(opponent)
    self.get.defense_happens.call(self, opponent)
  end
  def defense_succeeds(opponent)
    self.get.defense_succeeds.call(self, opponent)
  end
  def defense_fails(opponent)
    self.get.defense_fails.call(self, opponent)
  end
  def counter_happens(opponent)
    self.get.counter_happens.call(self, opponent)
  end
  def counter_succeeds(opponent)
    self.get.counter_succeeds.call(self, opponent)
  end
  def counter_fails(opponent)
    self.get.counter_fails.call(self, opponent)
  end
  def counter_defense_happens(opponent)
    self.defense_happens(opponent)
  end
  def counter_defense_succeeds(opponent)
    self.defense_succeeds(opponent)
  end
  def counter_defense_fails(opponent)
    self.defense_fails(opponent)
  end
end
