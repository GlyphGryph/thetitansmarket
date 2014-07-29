class Character < ActiveRecord::Base
  belongs_to :user
  belongs_to :world
  has_many :character_actions, :dependent => :destroy
  has_many :actions, :through => :character_actions

  validates_presence_of :user
  validates_presence_of :world
  validates_uniqueness_of :user, :scope => [:world]

  before_create :default_attributes
  after_create :name_character
  
  def name_character
    unless(self.name) 
      # If no name was provided, build one
      self.name = "Human Being "+self.id.to_s
      self.save!
    end
  end

  def default_attributes
   self.max_hp ||= 10
   self.hp ||= self.max_hp
   self.max_ap ||= 10
   self.ap ||= self.max_ap
   self.max_happy ||= 10
   self.happy ||= self.max_happy
   self.readied=false
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
end
