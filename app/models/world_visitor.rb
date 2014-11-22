class WorldVisitor < ActiveRecord::Base
  belongs_to :world
  validates_presence_of :world_id
  validates_presence_of :visitor_id

  def get
    element = Visitor.find(self.visitor_id)
    unless(element)
      raise "Could not find visitor for WorldVisitor with id #{self.id} looking for #{self.visitor_id}"
    end
    return element
  end

  def get_name(type=nil)
    return self.get.name
  end

  def execute
    return self.get.execute(self)
  end

  def depart
    self.destroy!
  end
end
