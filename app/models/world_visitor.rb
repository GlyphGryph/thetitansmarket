class WorldVisitor < ActiveRecord::Base
  belongs_to :world
  validates_presence_of :world_id
  validates_presence_of :visitor_id
  belongs_to :target, :polymorphic=>true

  before_create :default_attributes

  def default_attributes
    self.health ||= self.get.starting_health
    self.anger ||= self.get.starting_anger
    self.fear ||= self.get.starting_fear
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
    return self.get.execute(self)
  end

  def depart
    self.destroy!
  end

  def attacked_by(character)
    self.get.attacked(self, character)
  end

  def scared_by(character)
    self.get.scared(self, character)
  end

  def change_fear(amount)
    self.fear+=amount
    self.save!
  end

  def change_health(amount)
    self.health+=amount
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
end
