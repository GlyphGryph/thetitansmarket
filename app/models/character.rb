class Character < ActiveRecord::Base
  belongs_to :user
  belongs_to :world

  validates_presence_of :user
  validates_presence_of :world
  validates_uniqueness_of :user, :scope => [:world]
end
