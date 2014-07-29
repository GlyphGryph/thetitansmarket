class CharactersController < ApplicationController
  before_filter :authenticate_user!

  def overview
    @character = Character.find(params[:id])
    @world = @character.world
    @character_actions = @character.character_actions
    @actions = Action.all
  end
  
  def add_action
    character = Character.find(params[:id])
    action = Action.find(params[:action_id])
    character_action = CharacterAction.new(:character => character, :action => action)
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
end
