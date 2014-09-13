class Action
  extend CollectionTracker
  include Targetable
  attr_reader :id, :name, :description, :target_prompt

  def initialize(id, params={})
    @id = id
    @name = params[:name] || "Name Error"
    @description = params[:description] || "Description Error"

    @base_success_chance = params[:base_success_chance] || 100
    @success_modifiers = params[:success_modifiers] || {}

    @consumes = params[:consumes] || []
    @requires = params[:requires] || {}
    @result = params[:result] || lambda { |character, action| return "Function error." }
    @messages = params[:messages] || {}

    @valid_targets = @requires[:target] || {}
    @target_prompt = params[:target_prompt] || "Targeting Prompt error"

    @base_cost = params[:base_cost] || lambda { |character, target=nil| return 0 } 
    @cost_modifiers = params[:cost_modifiers] || {}

    self.class.add(@id, self)
  end

  def available?(character)
    available = true
    if(@requires)
      if(@requires[:possession])
        @requires[:possession].each do |required|
          available = available && character.possesses?(required[:id], required[:quantity])
        end
      end
      if(@requires[:knowledge])
        @requires[:knowledge].each do |required|
          available = available && character.knows?(required)
        end
      end
      if(@requires[:custom])
        @requires[:custom].each do |required|
          available = available && required.call(character)
        end
      end
      if(@requires[:target])
        # Character must have at least one of the valid targets
        found = false
        # If characters are a valid target, this is always true
        if(@valid_targets.keys.include?('character'))
          found = true
        else
          @valid_targets.each do |type, values|
            # If it's one of the others, find a match
            if(type==:possession)
              if(values.include?('all'))
                found = found || character.character_possessions.length > 0
              else
                values.each do |possibility|
                  found = found || character.possesses?(possibility)
                end
              end
            elsif(type==:idea)
              if(values.include?('all'))
                found = found || character.ideas.length > 0
              else
                values.each do |possibility|
                  found = found || character.considers?(possibility)
                end
              end
            elsif(type==:knowledge)
              if(values.include?('all'))
                found = found || character.knowledges.length > 0
              else
                values.each do |possibility|
                  found = found || character.knows?(possibility)
                end
              end
            elsif(type==:condition)
              if(values.include?('all'))
                found = found || character.character_conditions.length > 0
              else
                values.each do |possibility|
                  found = found || character.has_condition?(possibility)
                end
              end
            end
            if(found)
              break
            end
          end
        end
        available = available && found
      end
    end
    if(@consumes)
      @consumes.each do |required|
        # Consumed targets already have full specifications in the requires hash, do not repeat here
        # Otherwise, consumed items are still required
        if(required != :target)
          available = available && character.possesses?(required[:id], required[:quantity])
        end
      end
    end
    return available
  end

  def executable?(character, target=nil)
    available = self.available?(character)
    if(@requires)
      if(@requires[:target])
        if(target && target.get)
          valid_target_types = @requires[:target].keys
          found = false
          valid_target_types.each do |type|
            target_ids = @requires[:target][type]
            found = found || target_ids.include?('all') || target_ids.include?(target.get.id)
          end
          available = available && !target.get.id.nil?
        else
          available = false
        end
      end
    end
    return available
  end

  def unmodified_cost(character, target)
    cost = 0
    cost = @base_cost.call(character)
    return cost
  end
    
  def cost(character, target=nil)
    cost = self.unmodified_cost(character, target)
    # Note: If an action costs at least 1ap, the modifier should not be able to reduce the cost below zero
    # If an action is already free, it cannot be reduced at all (although it can be increased)
    modifier = 0.0
    if(@cost_modifiers[:damage])
      modifier += @cost_modifiers[:damage].to_f * character.damage_fraction
    end
    if(@cost_modifiers[:despair])
      modifier += @cost_modifiers[:despair].to_f * character.despair_fraction
    end
    if(@cost_modifiers[:possession])
      @cost_modifiers[:possession].each do |possession|
        if character.possesses?(possession[:id])
          modifier += possession[:modifier]
        end
      end
    end
    modifier = modifier.round

    cost += modifier
  end

  def result(character, target=nil)
    success_chance = self.success_chance(character)
    if(!self.executable?(character, target))
      if(target)
        outcome = ActionOutcome.new(:impossible, target.get.name)
      else
        outcome = ActionOutcome.new(:impossible)
      end
    else
      if(Random.new.rand(1..100) > success_chance)
        if(target)
          outcome = ActionOutcome.new(:failure, target.get.name)
        else
          outcome = ActionOutcome.new(:failure)
        end
      else
        outcome = @result.call(character, target)
      end
      @consumes.each do |consumed|
        if(consumed==:target)
          target.destroy!
        else
          consumed[:quantity].times do
            character.character_possessions.where(:possession_id=>consumed[:id]).first.destroy!
          end
        end
      end
    end
    success = (outcome.status != :failure)
    message = @messages[outcome.status] || lambda {|args| "Error: Message not provided for this outcome."}
    message = message.call(outcome.arguments)
    if(outcome.status != :impossible && success_chance < 100)
      message += " (#{ success ? "Success" : "Failure"}: #{success_chance}% chance of success)"
    end
    message += " (Required: #{@requires.inspect} / Consumed: #{@consumes.inspect})"
    return ActionResult.new(self.id, success, message, outcome.status)
  end
  
  def requires_target?
    return !!@requires[:target]
  end

  def success_chance(character)
    chance = @base_success_chance
    if(@success_modifiers[:possession])
      @success_modifiers[:possession].each do |possession|
        if character.possesses?(possession[:id])
          chance += possession[:modifier]
        end
      end
    end
    return chance
  end

  def type
    return "action"
  end
end

class ActionResult
  attr_accessor :success, :cost, :message, :status

  def initialize(action_id, success, message="Error: No Message Provided", status=:unknown)
    @success = success
    @message = message
    @action_id = action_id
    @status = status
  end
end

class ActionOutcome
  attr_accessor :status, :arguments
  def initialize(status, *arguments)
    @status = status
    @arguments = arguments
  end
end

class ActionTarget
  def self.find(type, id)
    if(type == "possession")
      return CharacterPossession.where(:id=>id).first
    elsif(type == "condition")
      return CharacterCondition.where(:id=>id).first
    elsif(type == "character")
      return Character.where(:id=>id).first
    elsif(type == "knowledge" || type =="idea")
      return CharacterKnowledge.where(:id=>id).first
    elsif(type == nil)
      return nil
    else
      raise "Invalid type provided. Could not find rule to handle target #{type}, #{id}."
    end
  end
end


# Load data
require 'data/action/all.rb'

