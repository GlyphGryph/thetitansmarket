class Character < ActiveRecord::Base
  serialize :history
  belongs_to :user
  belongs_to :world
  has_many :character_actions, :dependent => :destroy
  has_many :character_possessions, :dependent => :destroy
  has_many :character_conditions, :dependent => :destroy
  has_many :character_knowledges, :dependent => :destroy
  has_many :sent_proposals, :foreign_key => 'sender_id', :class_name => 'Proposal', :dependent => :destroy
  has_many :received_proposals, :foreign_key => 'receiver_id', :class_name => 'Proposal', :dependent => :destroy

  validates_presence_of :user
  validates_presence_of :world
  validates_uniqueness_of :user, :scope => [:world]

  before_create :default_attributes
  after_create :default_relationships
  
  def default_attributes
    self.max_hp ||= 10
    self.hp ||= self.max_hp
    self.max_ap ||= 10
    self.ap ||= self.max_ap
    self.max_happy ||= 10
    self.happy ||= self.max_happy
    self.readied=false
    self.name ||= "Avatar of "+self.user.name
    self.history ||= [["You were born from the machine, and thrust into the world."]]
  end

  def default_relationships
    self.character_conditions << CharacterCondition.new(:character => self, :condition_id => 'hunger')
    self.character_knowledges << CharacterKnowledge.new(:character => self, :knowledge_id => 'cognition', :known => true)
    self.character_knowledges << CharacterKnowledge.new(:character => self, :knowledge_id => 'play', :known => true)
    self.character_knowledges << CharacterKnowledge.new(:character => self, :knowledge_id => 'gestures', :known => true)
  end
  
  # Checks whether or not this character can add this action
  def can_add_action?(action_id)
    return Action.find(action_id).available?(self)
  end

  def change_happy(value)
    # Change the happy, up to max or down to zero
    new_happy = self.happy+value
    if(new_happy > self.max_happy)
      new_happy = self.max_happy
    elsif(new_happy < 0)
      new_happy = 0
    end
    # Only bother saving if the new happy is different
    if(self.happy != new_happy)
      self.happy = new_happy
      self.save!
    end
  end
  
  def change_ap(value)
    # Change the ap, up to max or down to zero
    new_ap = self.ap+value
    if(new_ap > self.max_ap)
      new_ap = self.max_ap
    elsif(new_ap < 0)
      new_ap = 0
    end
    # Only bother saving if the new ap is different
    if(self.ap != new_ap)
      self.ap = new_ap
      self.save!
    end
  end

  def consider(knowledge_id)
    unless(considers?(knowledge_id) || knows?(knowledge_id))
      self.character_knowledges << CharacterKnowledge.new(:character => self, :knowledge_id => knowledge_id, :known => false)
    end
  end

  def considers?(knowledge_id)
    return !(self.ideas.where(:knowledge_id => knowledge_id).empty?)
  end

  # Returns the total cost of all actions in this character's action queue
  def cost_of_all_actions
    cost = 0
    self.character_actions.each do |character_action|
      cost+=character_action.get.cost(self)
    end
    return cost
  end

  def damage(amount=1)
    self.hp-=amount
    self.save!
  end

  def eat(amount=1)
    if(self.possesses?('food'))
      food = self.character_possessions.where(:possession_id => 'food').first
      if(self.knows?("basic_farming"))
        CharacterPossession.new(:character => self, :possession_id => 'seed', :variant=>food.variant).save!
      end
      food.destroy!
      return true
    else
      return false
    end
  end

  def earlier_history
    return history - recent_history
  end

  def get
    return self
  end

  def ideas
    character_knowledges.where(:known=>false)
  end

  def knows?(knowledge_id)
    return !(self.knowledges.where(:knowledge_id => knowledge_id).empty?)
  end

  def knowledges
    character_knowledges.where(:known=>true)
  end

  def learn(knowledge_id)
    if(considers?(knowledge_id))
      self.ideas.where(:knowledge_id => knowledge_id).first.learn
    elsif(!knows?(knowledge_id))
      self.character_knowledges << CharacterKnowledge.new(:character => self, :knowledge_id => knowledge_id, :known => true)
    end
  end

  def fraction_hp_remaining
    return self.hp.to_f / self.max_hp.to_f
  end

  def fraction_hp_missing
    1.0 - self.fraction_hp_remaining.to_f
  end

  def fraction_happy_remaining
    return self.happy.to_f / self.max_happy.to_f
  end

  def fraction_happy_missing
    1.0 - self.fraction_happy_remaining.to_f
  end
  
  def possesses?(possession_id)
    return !(self.character_possessions.where(:possession_id => possession_id).empty?)
  end

  def potential_actions
    return Action.all.select do |action|
      action.available?(self)
    end
  end

  def ready?
    return self.readied
  end

  def ready
    self.readied = true
    self.save!
  end

  def recent_history
    return history.last
  end

  def unready
    self.readied = false
    self.save!
  end

  def recent_proposals
    return self.received_proposals.where(:turn => self.world.turn) + self.sent_proposals.where(:turn => self.world.turn)
  end

  def unread_proposals
    return self.recent_proposals.reject{|proposal| proposal.viewed_by?(self)}
  end

  def type
    "character"
  end

  def execute
    self.unready
    cost_so_far = 0
    new_history = []

    # Process this character's actions
    self.character_actions.each do |character_action|
      action = character_action.get
      cost_so_far += action.cost(self)
      if(cost_so_far <= self.ap)
        new_history << action.result(self, character_action)
      end
    end
    if(cost_so_far > self.ap)
      new_history << "You ran out of energy partway through, and couldn't finish what you had planned to do."
    end

    # Close out any unclosed proposals this character made this turn
    self.recent_proposals.each do |proposal|
      if(proposal.status == 'open')
        proposal.cancel
      end
    end

    # Restore character's lost ap for their next turn, before conditions potentially reduce it again
    self.ap = self.max_ap

    # Process this character's active conditions
    self.character_conditions.each do |character_condition|
      condition = character_condition.get
      effect = condition.result(self)
      if(effect && !effect.empty?)
        new_history << effect
      end
    end

    self.history << new_history
    self.save!
    self.character_actions.destroy_all
  end
end
