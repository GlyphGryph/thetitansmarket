module DataLoader
  def load(data)
    data.each do |definition|
      self.add_new(definition)
    end
  end
end
