class WorldVisitor < ActiveRecord::Base
  include ConceptModule
  include BodyInterface

  belongs_to :world
  validates_presence_of :world_id
  validates_presence_of :visitor_id
  belongs_to :target, :polymorphic=>true

  before_create :default_attributes

  def default_attributes
    self.anger = self.get.starting_anger
    self.fear = self.get.starting_fear
  end
  
  def starting_health
    self.get.starting_health
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
    self.save!
  end

  def change_anger(amount)
    self.anger+=amount
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
end
