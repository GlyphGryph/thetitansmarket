class Action < ActiveRecord::Base
  has_many :character_actions, :dependent => :destroy
  has_many :characters, :through => :character_actions
end
