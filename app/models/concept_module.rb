module ConceptModule
  def self.included(base)
    base.class_eval do
      has_many :world_visitors, :as => :target, :dependent => :nullify
    end
  end
  
  def observers
    return world_visitors
  end
end
