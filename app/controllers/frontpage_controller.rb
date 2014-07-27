class FrontpageController < ApplicationController
  def index
    @resource_name = "user"
    @worlds = World.all
  end
end
