class Log < ActiveRecord::Base
  belongs_to :owner, :polymorphic=>true
  validates_presence_of :owner
  has_many :log_entries, :dependent => :destroy

  def make_entry(status, body)
    new_entry = LogEntry.new(:status => status, :body => body)
    self.log_entries << new_entry
    new_entry.save!
  end

  def make_entries(status, new_entries)
    new_entries.each do |new_entry|
      self.make_entry(status, new_entry)
    end
  end

  def add_entry(new_entry)
    log_entries << new_entry
    new_entry.save!
  end
    
  def add_entries(new_entries)
    new_entries.each do |new_entry|
      self.add_entry(new_entry)
    end
  end

  def empty?
    return self.log_entries.empty?
  end
end
