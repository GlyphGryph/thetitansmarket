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

  def age
    self.duration-=1
    if(self.duration < 0)
      self.destroy!
    else
      self.save!
    end
  end
end
