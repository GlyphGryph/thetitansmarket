class CharacterAction < ActiveRecord::Base
  belongs_to :character
  belongs_to :action
end
