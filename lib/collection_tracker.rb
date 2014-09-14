module CollectionTracker
  def entries
    @entries ||= {}
  end

  def all
    entries.values
  end

  def find(id)
    entries[id]
  end

  def add(id, value)
    entries[id]=value
  end
end
