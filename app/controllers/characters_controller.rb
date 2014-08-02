class CharactersController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_character
  before_filter :check_valid_owner, :except => :show

  def overview
    @world = @character.world
    @character_actions = @character.character_actions
    @actions = Action.all
    @inventory = @character.character_possessions.inject({}) do |result, value|
      possession = value.possession
      if(result[possession.id]) 
        result[possession.id][:count]+=1
      else
        result[possession.id]=OpenStruct.new(:value=>possession, :count=>1)
      end
      result
    end
    @conditions = @character.character_conditions.map(&:condition)
    @history = @character.recent_history
    @queue_cost = @character.cost_of_all_actions
    @other_characters = @world.characters.reject{|c| c==@character}
    @ready_to_execute = @world.ready_to_execute?
    @unready_characters = @world.unready_characters
  end
  
  def add_action
    action = Action.find(params[:action_id])
    character_action = CharacterAction.new(:character => @character, :action_id => action.id)
    respond_to do |format|
      if(character_action.save)
        format.html { redirect_to character_overview_path }
      else
        format.html { redirect_to character_overview_path, :alert => character_action.errors.full_messages.to_sentence}
      end
    end
  end

  def remove_action
    character_action = CharacterAction.find(params[:character_action_id])
    character_action.destroy
    respond_to do |format|
      if(character_action.destroyed?)
        format.html { redirect_to character_overview_path }
      else
        format.html { redirect_to character_overview_path, :alert => "Could not remove action."}
      end
    end
  end

  def ready
    @character.ready
    respond_to do |format|
      if(@character.ready?)
        format.html { redirect_to character_overview_path }
      else
        format.html { redirect_to character_overview_path, :alert => "Could not ready character."}
      end
    end
  end

  def unready
    @character.unready
    respond_to do |format|
      if(!@character.ready?)
        format.html { redirect_to character_overview_path }
      else
        format.html { redirect_to character_overview_path, :alert => "Could not unready character."}
      end
    end
  end

  def execute
    world = World.find(params[:world_id])
    respond_to do |format|
      if(world.execute)
        format.html { redirect_to character_overview_path, :notice => "The world turns..." }
      else
        format.html { redirect_to character_overview_path, :alert => "The world could not turn."}
      end
    end
  end

  def examine
    @target = Character.find(params[:character_id])
  end

  def history
    @history = @character.earlier_history
    @recent_history = @character.recent_history
  end

  def show
  end

private
  def find_character
    @character = Character.find(params[:id])
  end

  def check_valid_owner
    if(!current_user.characters.include?(@character))
      redirect_to :action => :show
    end
  end
end
