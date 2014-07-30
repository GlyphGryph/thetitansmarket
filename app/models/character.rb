class Character < ActiveRecord::Base
  serialize :history
  belongs_to :user
  belongs_to :world
  has_many :character_actions, :dependent => :destroy

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
    new_history = []
    self.character_actions.each do |character_action|
      action = character_action.action
      new_history << action.function.call
    end
    self.history << new_history
    self.save!
    self.character_actions.destroy_all
  end
end
