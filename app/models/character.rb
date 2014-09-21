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
    self.max_health ||= 10
    self.health ||= self.max_health
    self.max_vigor ||= 10
    self.vigor ||= self.max_vigor
    self.max_resolve ||= 10
    self.resolve ||= self.max_resolve
    self.readied=false
    self.name ||= "Avatar of "+self.user.name
    self.history ||= [["You were born from the machine, and thrust into the world."]]
  end

  def default_relationships
    self.character_conditions << CharacterCondition.new(:character => self, :condition_id => 'resilience')
    self.character_conditions << CharacterCondition.new(:character => self, :condition_id => 'hunger')
    self.character_conditions << CharacterCondition.new(:character => self, :condition_id => 'weariness')
    self.character_knowledges << CharacterKnowledge.new(:character => self, :knowledge_id => 'cognition', :progress => Knowledge.find('cognition').components)
    self.character_knowledges << CharacterKnowledge.new(:character => self, :knowledge_id => 'play', :progress => Knowledge.find('play').components)
    self.character_knowledges << CharacterKnowledge.new(:character => self, :knowledge_id => 'gestures', :progress => Knowledge.find('gestures').components)
  end
  
  # Checks whether or not this character can add this action
  def add_action(action_id, target_type=nil, target_id=nil)
    action = Action.find(action_id)
    target = ActionTarget.find(target_type, target_id) 
    execute_action(action, target)
  end

  def execute_action(action, target)
    cost = action.cost(self)
    if(cost <= self.vigor)
      result = action.result(self, target)
      if(result.status != :impossible)
        self.change_vigor(-cost)
      end
      self.recent_history << result.message
    else
      if(self.vigor > 0)
        if(target)
          CharacterAction.new(:character => self, :action_id => action.id, :target_type => target.get.type, :target_id => target.id, :stored_vigor => self.vigor).save!
        else
          CharacterAction.new(:character => self, :action_id => action.id, :stored_vigor => self.vigor).save!
        end
        self.change_vigor(-self.vigor)
      else
        if(target)
          CharacterAction.new(:character => self, :action_id => action.id, :target_type => target.get.type, :target_id => target.id).save!
        else
          CharacterAction.new(:character => self, :action_id => action.id).save!
        end
      end
    end
    self.save!
  end

  def can_add_action?(action_id)
    return Action.find(action_id).available?(self)
  end

  def change_resolve(value)
    # Change the resolve, up to max or down to zero
    new_resolve = self.resolve+value
    if(new_resolve > self.max_resolve)
      new_resolve = self.max_resolve
    end
    
    # If our morale falls to or below zero, add nihilism and remove resilience
    if(!self.has_condition?("nihilism") && new_resolve <= 0)
      self.character_conditions.where(:condition_id => 'resilience').destroy_all
      self.character_conditions << CharacterCondition.new(:character => self, :condition_id => 'nihilism')
      if(self.has_condition?("pure_grit"))
        self.die
      end
    end

    # If we were suffering from nihilism, but we've regained morale, remove it and restore resilience
    if(self.has_condition?("nihilism") && new_resolve > 0)
      self.character_conditions << CharacterCondition.new(:character => self, :condition_id => 'resilience')
      self.character_conditions.where(:condition_id => 'nihilism').destroy_all
    end

    # Only bother saving if the new resolve is different
    if(self.resolve != new_resolve)
      self.resolve = new_resolve
      self.save!
    end
  end
  
  def change_vigor(value)
    # Change the vigor, up to max or down to zero
    new_vigor = self.vigor+value
    if(new_vigor > self.max_vigor)
      new_vigor = self.max_vigor
    elsif(new_vigor < 0)
      new_vigor = 0
    end
    # Only bother saving if the new vigor is different
    if(self.vigor != new_vigor)
      self.vigor = new_vigor
      self.save!
    end
  end

  def change_health(value)
    new_health = self.health
    if(self.has_condition?('pure_grit') && value <= 0)
      new_health = 0
      change_resolve(value)
    else
      # Change the vigor, up to max or down to zero

      new_health += value
      if(new_health > self.max_health)
        new_health = self.max_health
      elsif(new_health < 1)
        # Minimum health is zero, which triggers PURE GRIT. Further damage is dealt to morale instead.
        self.change_resolve(new_health*2)
        new_health = 0
        self.character_conditions << CharacterCondition.new(:character => self, :condition_id => 'pure_grit')
        if(self.has_condition?('nihilism'))
          self.die
        end
      end

      if(self.has_condition?('pure_grit') && new_health > 0)
        self.character_conditions.where(:condition_id => 'pure_grit').destroy_all
      end
    end
    # Only bother saving if the new vigor is different
    if(self.health != new_health)
      self.health = new_health
      self.save!
    end  
  end

  def consider(knowledge_id)
    unless(considers?(knowledge_id) || knows?(knowledge_id))
      self.character_knowledges << CharacterKnowledge.new(:character => self, :knowledge_id => knowledge_id, :progress => 0)
    end
  end

  def considers?(knowledge_id)
    return !(self.ideas.where(:knowledge_id => knowledge_id).empty?)
  end

  def knowledge_progress(knowledge_id)
    found = self.character_knowledges.where(:knowledge_id => knowledge_id)
    if(found.empty?)
      return 0
    else
      return found.first.progress
    end
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
    self.recent_history << "You have died."
    self.world = nil
  end

  def dead?
    return self.world.nil?
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
    return history.slice(0,(history.length-1))
  end

  def get
    return self
  end

  def has_condition?(condition_id)
    return !(self.character_conditions.where(:condition_id => condition_id).empty?)
  end

  def ideas
    ids = character_knowledges.select{|knowledge| !knowledge.known?}.map(&:id)
    CharacterKnowledge.where(:id => ids)
  end

  def knows?(knowledge_id)
    return !(self.knowledges.where(:knowledge_id => knowledge_id).empty?)
  end

  def knowledges
    ids = character_knowledges.select{|knowledge| knowledge.known?}.map(&:id)
    CharacterKnowledge.where(:id => ids)
  end

  def learn(knowledge_id, amount=1)
    if(considers?(knowledge_id))
      self.ideas.where(:knowledge_id => knowledge_id).first.learn(amount)
    elsif(!knows?(knowledge_id))
      new_knowledge = CharacterKnowledge.new(:character => self, :knowledge_id => knowledge_id, :progress => 0)
      self.character_knowledges << new_knowledge
      new_knowledge.learn(amount)
    end
  end

  def health_fraction
    return self.health.to_f / self.max_health.to_f
  end

  def damage_fraction
    1.0 - self.health_fraction.to_f
  end

  def resolve_fraction
    return self.resolve.to_f / self.max_resolve.to_f
  end

  def despair_fraction
    1.0 - self.resolve_fraction.to_f
  end
 
  def possesses?(possession_id, quantity=1)
    return (self.character_possessions.where(:possession_id => possession_id).size >= quantity)
  end

  def possessions_list
    generics = {}
    self.character_possessions.each do |character_possession|
      tag = character_possession.possession_id+"/"+character_possession.possession_variant.key
      generics[tag] ||= OpenStruct.new(
        :id => character_possession.possession_id,
        :variant => character_possession.possession_variant, 
        :description => character_possession.get.description,
        :count => 0
      )
      generics[tag].count += 1
    end
    return generics.values
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
    
    self.history << []
    new_history = self.recent_history

    # Restore character's lost vigor for their next turn, before conditions potentially reduce it again
    self.vigor = self.max_vigor

    # Close out any unclosed proposals this character made this turn
    self.recent_proposals.each do |proposal|
      if(proposal.status == 'open')
        proposal.cancel
      end
    end

    # Process this character's active conditions
    self.character_conditions.each do |character_condition|
      condition = character_condition.get
      effect = condition.result(self)
      if(effect && !effect.empty?)
        new_history << effect
      end
    end
    
    # Processing conditions may have killed us - if so, skip the beginning of next turn stuff
    unless(self.dead?)
      # Process this character's queued actions until we run out of actions or run out of ap
      continue_processing = true
      while(continue_processing)
        next_up = self.character_actions.first
        # Stop processing if there are no more actions or the next action is too expensive
        if(next_up)
          cost_remaining = next_up.get.cost(self)
          if(next_up.stored_vigor)
            cost_remaining -= next_up.stored_vigor
          end
          # If we have a negative cost somehow, treat it as a free action
          if(cost_remaining < 0)
            cost_remaining = 0
          end
          if(cost_remaining <= self.vigor)
            action = next_up.get
            result = action.result(self, next_up.target)
            new_history << result.message
            if(result.status != :impossible)
              self.change_vigor(-cost_remaining)
            end
            next_up.destroy!
          else
            next_up.stored_vigor = self.vigor
            self.change_vigor(-self.vigor)
            next_up.save!
            continue_processing = false
          end
        else
          continue_processing = false
        end
      end
    end

    self.save!
  end

  # Dev cheats
  def godmode
    self.health=1000
    self.max_health=1000
    self.vigor=1000
    self.max_vigor=1000
    self.resolve=1000
    self.max_resolve=1000
    self.save!
  end
end

