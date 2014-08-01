class Character < ActiveRecord::Base
  serialize :history
  belongs_to :user
  belongs_to :world
  has_many :character_actions, :dependent => :destroy
  has_many :character_possessions, :dependent => :destroy

  validates_presence_of :user
  validates_presence_of :world
  validates_uniqueness_of :user, :scope => [:world]

  before_create :default_attributes
  
  def default_attributes
    self.max_hp ||= 10
    self.hp ||= self.max_hp
    self.max_ap ||= 10
    self.ap ||= self.max_ap
    self.max_happy ||= 10
    self.happy ||= self.max_happy
    self.readied=false
    self.name ||= "Human Being"
    self.history ||= [["You were born from the machine, and thrust into the world."]]
  end
  
  # Checks whether or not this character has enough AP to add additional actions.
  def can_add_action?(action_id)
    cost_of_action = Action.find(action_id).cost.call(self)
    return (self.ap - self.cost_of_all_actions) >= cost_of_action
  end

  # Returns the total cost of all actions in this character's action queue
  def cost_of_all_actions
    cost = 0
    self.character_actions.each do |character_action|
      cost+=character_action.action.cost.call(self)
    end
    return cost
  end

  def recent_history
    return history.last
  end

  def ready?
    return self.readied
  end

  def ready
    self.readied = true
    self.save!
  end

  def unready
    self.readied = false
    self.save!
  end

  def execute
    self.unready
    cost_so_far = 0
    new_history = []
    self.character_actions.each do |character_action|
      action = character_action.action
      cost_so_far += action.cost.call(self)
      if(cost_so_far <= self.ap)
        new_history << action.result.call(self)
      end
    end
    if(cost_so_far > self.ap)
      new_history << "You ran out of energy partway through, and couldn't finish what you had planned to do."
    end
    self.history << new_history
    self.save!
    self.character_actions.destroy_all
  end
end
