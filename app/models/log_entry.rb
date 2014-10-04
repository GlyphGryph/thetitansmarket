class LogEntry < ActiveRecord::Base
  belongs_to :log, :dependent => :destroy
  validates_presence_of :log, :body, :type
  before_validation :default_attributes, :on => :create
  validates :type, :inclusion => { :in => %w{passive success failure important} }
  def default_attributes
    self.type ||= "standard"
  end 
end
