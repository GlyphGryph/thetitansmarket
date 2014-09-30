class FrontpageController < ApplicationController
  def index
    @resource_name = "user"
    @worlds = World.all.sort_by(&:id)
    @user_worlds = []
    if user_signed_in?
      @characters = current_user.characters
      @characters.each do |character|
        @user_worlds << character.world
      end
      @traits = Trait.all
    end
  end
end
