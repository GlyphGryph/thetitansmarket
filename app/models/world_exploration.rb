class WorldExploration < ActiveRecord::Base
  belongs_to :world
  validates_presence_of :world_id
  validates_presence_of :exploration_id

  def get
    Exploration.find(self.exploration_id)
  end
end
