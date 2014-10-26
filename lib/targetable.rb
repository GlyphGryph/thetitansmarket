module Targetable
  # Takes a actor, and returns a list of valid targets, sorted by type, that actor can select for this action
  def targets(actor)
    valid = {}
    @valid_targets.each do |target_type, values|
      target_objects = []
      if(target_type == :possession)
        if(values.include?('all'))
          target_objects = actor.character_possessions
        else
          actor.character_possessions.each do |character_possession|
            if(values.include?(character_possession.possession_id))
              target_objects << character_possession
            end
          end
        end
      elsif(target_type == :knowledge)
        if(values.include?('all'))
          # Only pull from knowledges ACTUALLY known.
          target_objects = actor.knowledges
        else
          actor.knowledges.each do |character_knowledge|
            if(values.include?(character_knowledge.knowledge_id))
              target_objects << character_knowledge
            end
          end
        end
      elsif(target_type == :idea)
        if(values.include?('all'))
          # Only pull from knowledges considered but not yet known.
          target_objects = actor.ideas
        else
          actor.ideas.each do |character_knowledge|
            if(values.include?(character_knowledge.knowledge_id))
              target_objects << character_knowledge
            end
          end
        end
      elsif(target_type == :character)
        if(values.include?('all'))
          target_objects = actor.world.characters
        end
      elsif(target_type == :condition)
        if(values.include?('all'))
          target_objects = actor.character_conditions
        else
          actor.character_conditions.each do |character_condition|
            if(values.include?(character_condition.condition_id))
              target_objects << character_condition
            end
          end
        end
      elsif(target_type == :body)
        #TODO
      else
        raise "Invalid target type '#{target_type.inspect}' for Action: valid targets"
      end
      valid[target_type]=target_objects
    end
    return valid
  end

  def targets_by_category(character)
    targets_by_category = {}
    self.targets(character).each do |key, targets|
      if(targets.count > 0)
        targets_by_category[key] = OpenStruct.new(:name => self.category_name(key), :targets => targets)
      end
    end

    return targets_by_category
  end

  def category_name(category_id)
    name = "Unknown Type"
    if(category_id == :possession)
      name = "Possessions"
    elsif(category_id == :condition)
      name = "Conditions"
    elsif(category_id == :character)
      name = "Characters"
    elsif(category_id == :knowledge)
      name = "Knowledge"
    elsif(category_id == :idea)
      name = "Ideas"
    elsif(category_id == :body)
      name = "Body Parts"
    end
    return name
  end

  def requires_target?
    return requires[:target]
  end

  def targetable(type, id)
    if(self.valid_targets[type] && (self.valid_target[type].include?(id) || self.valid_target[type].include?('all')))
      return true
    else
      return false
    end
  end
end
