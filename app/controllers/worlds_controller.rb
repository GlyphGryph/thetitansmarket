class WorldsController < ApplicationController
  before_filter :authenticate_user!
  def join
    if(params[:trait_id])
      trait = Trait.find(params[:trait_id])
    else
      trait = Trait.all.sample
    end
    @world = World.find(params[:id])
    ActiveRecord::Base.transaction do
      @character = @world.join(current_user)
      CharacterTrait.new(:trait_id => trait.id, :character => @character).save!
    end
    respond_to do |format|
      if(@character.new_record?)
        format.html { redirect_to root_path, :alert => "Failed to join world." }
      else
        format.html { redirect_to root_path, :notice => "World joined successfully."}
      end
    end
  end

  def new
    world = World.new
    respond_to do |format|
      if(world.save)
        format.html { redirect_to root_path, :alert => "World creation success" }
      else
        format.html { redirect_to root_path, :notice => "World creation failed."}
      end
    end
  end
end
