class WorldsController < ApplicationController
  before_filter :authenticate_user!
  def join
    @world = World.find(params[:id])
    @character = @world.join(current_user)
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
