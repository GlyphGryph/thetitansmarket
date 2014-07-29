class Character < ActiveRecord::Base
  belongs_to :user
  belongs_to :world
  has_many :character_actions
  has_many :actions, :through => :character_actions

  validates_presence_of :user
  validates_presence_of :world
  validates_uniqueness_of :user, :scope => [:world]

  after_save :name_character
  
  def name_character
    unless(self.name) 
      # If no name was provided, build one
      self.name = "Human Being "+self.id.to_s
      self.save!
    end
  end

  def ready?
    return self.ready
  end
end
