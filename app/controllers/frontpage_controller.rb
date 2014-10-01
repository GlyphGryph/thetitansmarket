class FrontpageController < ApplicationController
  def index
    @resource_name = "user"
    @worlds = World.all.sort_by(&:id)
    if user_signed_in?
      @characters = current_user.characters
      @worlds_and_characters = @worlds.map do |world| 
        found = nil
        @characters.each do |character|
          if(world == character.world)
            found = character
            break
          end
        end
        OpenStruct.new(:world => world, :character => found)
      end
      @traits = Trait.all
      @deceased_characters = @characters.select{|character| character.world.nil?}
    end
  end
end
