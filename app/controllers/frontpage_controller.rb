class FrontpageController < ApplicationController
  def index
    @resource_name = "user"
    @worlds = World.all
    if user_signed_in?
      @characters = current_user.characters
    end
  end
end
