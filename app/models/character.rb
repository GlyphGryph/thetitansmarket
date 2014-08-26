class CharacterValidator < ActiveModel::Validator
  def validate(record)
    if(record.world)
      previous_characters_this_world = record.user.characters.where.not(:id=>record.id).where(:world => record.world)
      if(previous_characters_this_world.count > 0)
        record.errors[:character] << " can not join this world. Another character from this use has already joined it."
      end
    end
  end
end

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
  include ActiveModel::Validations
  validates_with CharacterValidator

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
    self.character_conditions << CharacterCondition.new(:character => self, :condition_id => 'resilience')
    self.character_conditions << CharacterCondition.new(:character => self, :condition_id => 'hunger')
    self.character_conditions << CharacterCondition.new(:character => self, :condition_id => 'weariness')
    self.character_knowledges << CharacterKnowledge.new(:character => self, :knowledge_id => 'cognition', :known => true)
    self.character_knowledges << CharacterKnowledge.new(:character => self, :knowledge_id => 'play', :known => true)
    self.character_knowledges << CharacterKnowledge.new(:character => self, :knowledge_id => 'gestures', :known => true)
  end
  
  # Checks whether or not this character can add this action
  def add_action(action_id, target_type=nil, target_id=nil)
    action = Action.find(action_id)
    cost = action.cost(self)
    if(cost <= self.ap)
      self.change_ap(-cost)
      if(target_type)
        self.recent_history << action.result(self, target).message
      else
        self.recent_history << action.result(self).message
      end
    else
      CharacterAction.new(:character => self, :action_id => action.id, :target_type => target_type, :target_id => target_id).save!
    end
    self.save!
  end

  def can_add_action?(action_id)
    return Action.find(action_id).available?(self)
  end

  def change_happy(value)
    # Change the happy, up to max or down to zero
    new_happy = self.happy+value
    if(new_happy > self.max_happy)
      new_happy = self.max_happy
    end
    
    # If our morale falls to or below zero, add nihilism and remove resilience
    if(!self.has_condition?("nihilism") && new_happy <= 0)
      self.character_conditions.where(:condition_id => 'resilience').destroy_all
      self.character_conditions << CharacterCondition.new(:character => self, :condition_id => 'nihilism')
      if(self.has_condition?("pure_grit"))
        self.die
      end
    end

    # If we were suffering from nihilism, but we've regained morale, remove it and restore resilience
    if(self.has_condition?("nihilism") && new_happy > 0)
      self.character_conditions << CharacterCondition.new(:character => self, :condition_id => 'resilience')
      self.character_conditions.where(:condition_id => 'nihilism').destroy_all
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

  def change_hp(value)
    new_hp = self.hp
    if(self.has_condition?('pure_grit') && value <= 0)
      new_hp = 0
      change_happy(value)
    else
      # Change the ap, up to max or down to zero

      new_hp += value
      if(new_hp > self.max_hp)
        new_hp = self.max_hp
      elsif(new_hp < 1)
        # Minimum hp is zero, which triggers PURE GRIT. Further damage is dealt to morale instead.
        self.change_happy(new_hp*2)
        new_hp = 0
        self.character_conditions << CharacterCondition.new(:character => self, :condition_id => 'pure_grit')
        if(self.has_condition?('nihilism'))
          self.die
        end
      end

      if(self.has_condition?('pure_grit') && new_hp > 0)
        self.character_conditions.where(:condition_id => 'pure_grit').destroy_all
      end
    end
    # Only bother saving if the new ap is different
    if(self.hp != new_hp)
      self.hp = new_hp
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

  def die
    self.history << ["You have died."]
    self.world = nil
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

  def has_condition?(condition_id)
    return !(self.character_conditions.where(:condition_id => condition_id).empty?)
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
      new_knowledge = CharacterKnowledge.new(:character => self, :knowledge_id => knowledge_id)
      self.character_knowledges << new_knowledge
      new_knowledge.learn
    end
  end

  def hp_fraction
    return self.hp.to_f / self.max_hp.to_f
  end

  def damage_fraction
    1.0 - self.hp_fraction.to_f
  end

  def happy_fraction
    return self.happy.to_f / self.max_happy.to_f
  end

  def despair_fraction
    1.0 - self.happy_fraction.to_f
  end
 
  def possesses?(possession_id, quantity=1)
    return (self.character_possessions.where(:possession_id => possession_id).size >= quantity)
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
        new_history << action.result(self, character_action).message
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

  # Dev cheats
  def godmode
    self.hp=1000
    self.max_hp=1000
    self.ap=1000
    self.max_ap=1000
    self.happy=1000
    self.max_happy=1000
    self.save!
  end
end
