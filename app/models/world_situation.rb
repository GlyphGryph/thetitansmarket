class WorldSituation < ActiveRecord::Base
  belongs_to :world
  validates_presence_of :world_id
  validates_presence_of :situation_id

  def get
    element = Situation.find(self.situation_id)
    unless(element)
      raise "Could not find situation for WorldSituation with id #{self.id} looking for #{self.situation_id}"
    end
    return element
  end

  def get_name(type=nil)
    return self.get.name
  end

  def should_die?
    return self.duration <= 0
  end
end
