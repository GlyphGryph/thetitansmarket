class CharactersController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_character
  before_filter :check_valid_owner, :except => :show

  def overview
    @world = @character.world
    # If this character has no world, it is a ghost, and can't be shown the normal overview page
    if(@world.nil?)
      redirect_to :action => :show
    else
      @character_actions = @character.character_actions
      @actions = @character.potential_actions
      @inventory = @character.possessions_list
      @knowledges = @character.knowledges
      @ideas = @character.ideas
      @conditions = @character.character_conditions
      @history = @character.recent_history
      @other_characters = @world.characters.reject{|c| c==@character}
      @unready_characters = @world.unready_characters
    end
  end
  
  def add_action
    action = Action.find(params[:action_id])
    if(params[:target_type] && params[:target_id])
      redirect_to :add_action_with_target
      return
    elsif(action.requires_target?)
      redirect_to :find_action_target
      return
    end
    @character.add_action(action.id)
    respond_to do |format|
      format.html { redirect_to character_overview_path }
    end
  end
  
  def add_action_with_target
    action = Action.find(params[:action_id])
    target_type = params[:target_type]
    target_id = params[:target_id]
    respond_to do |format|
      if(@character.add_action(action.id, target_type, target_id))
        format.html { redirect_to character_overview_path }
      else
        format.html { redirect_to character_overview_path, :alert => character_action.errors.full_messages.to_sentence}
      end
    end
  end

  def find_action_target
    @action = Action.find(params[:action_id])
    @targets_by_category = {}
    @action.targets(@character).each do |key, targets|
      name = "Unknown Type"
      if(key == :possession)
        name = "Possessions"
      elsif(key == :condition)
        name = "Conditions"
      elsif(key == :character)
        name = "Characters"
      elsif(key == :knowledge)
        name = "Knowledge"
      elsif(key == :idea)
        name = "Ideas"
      end
      @targets_by_category[key] = OpenStruct.new(:name => name, :targets => targets)
    end
  end

  def remove_action
    character_action = CharacterAction.find(params[:character_action_id])
    if(character_action.stored_vigor)
      @character.change_vigor(character_action.stored_vigor)
    end
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
  end

  def show
  end
  
  ######## CHEAT ########
  def godmode
    @character.godmode
    redirect_to :character_overview
  end

  def wish
    if(params[:type] == "possession")
      quantity = (params[:quantity] || 1).to_i
      if(Possession.find(params[:target_id]))
        quantity.times do
          CharacterPossession.new(:character_id => @character.id, :possession_id => params[:target_id]).save!
        end
        notice = "Acquired #{quantity} of #{params[:target_id]}"
      else
        notice = "Wish failed, invalid id #{params[:target_id]}."
      end
    elsif(params[:type] == "knowledge")
      if(Knowledge.find(params[:target_id]))
        @character.learn(params[:target_id])
        notice = "Learned #{params[:target_id]}"
      else
        notice = "Wish failed, invalid id #{params[:target_id]}."
      end
    end
    redirect_to :character_overview, :notice => notice
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
