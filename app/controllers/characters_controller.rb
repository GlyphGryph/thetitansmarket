class CharactersController < ApplicationController
  before_filter :authenticate_user!

  def overview
    @character = Character.find(params[:id])
    @world = @character.world
  end
end
