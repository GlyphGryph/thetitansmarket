class Action < ActiveRecord::Base
  has_many :character_actions
  has_many :characters, :through => :character_actions
end
