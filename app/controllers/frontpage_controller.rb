class FrontpageController < ApplicationController
  def index
    @resource_name = "user"
    @worlds = World.all
    @user_worlds = []
    if user_signed_in?
      @characters = current_user.characters
      @characters.each do |character|
        @user_worlds << character.world
      end
    end
  end
end
