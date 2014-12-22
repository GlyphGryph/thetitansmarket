module CollectionTracker
  def entries
    @entries ||= {}
  end

  def all
    entries.values
  end

  def find(id)
    entries[id.to_sym]
  end

  def add(id, value)
    entries[id.to_sym]=value
  end

  def add_new(params)
    object = self.new(params)
    entries[object.id.to_sym] = object
  end
end
