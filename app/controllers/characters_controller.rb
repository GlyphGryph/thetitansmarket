class CharactersController < ApplicationController
  before_filter :authenticate_user!

  def overview
    @character = Character.find(params[:id])
    @world = @character.world
    @character_actions = @character.character_actions
    @actions = Action.all
    @history = @character.history.last
    @ready_to_execute = @world.ready_to_execute?
    @unready_characters = @world.unready_characters
  end
  
  def add_action
    character = Character.find(params[:id])
    action = Action.find(params[:action_id])
    character_action = CharacterAction.new(:character => character, :action_id => action.id)
    respond_to do |format|
      if(character_action.save)
        format.html { redirect_to character_overview_path }
      else
        format.html { redirect_to character_overview_path, :alert => "Could not add action."}
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
    character = Character.find(params[:id])
    character.ready
    respond_to do |format|
      if(character.ready?)
        format.html { redirect_to character_overview_path }
      else
        format.html { redirect_to character_overview_path, :alert => "Could not ready character."}
      end
    end
  end

  def unready
    character = Character.find(params[:id])
    character.unready
    respond_to do |format|
      if(!character.ready?)
        format.html { redirect_to character_overview_path }
      else
        format.html { redirect_to character_overview_path, :alert => "Could not unready character."}
      end
    end
  end

  def execute
    character = Character.find(params[:id])
    world = World.find(params[:world_id])
    respond_to do |format|
      if(world.execute)
        format.html { redirect_to character_overview_path, :notice => "The world turns..." }
      else
        format.html { redirect_to character_overview_path, :alert => "The world could not turn."}
      end
    end
  end
end
