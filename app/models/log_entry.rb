class LogEntry < ActiveRecord::Base
  belongs_to :log, :dependent => :destroy
  validates_presence_of :log, :body, :status
  validates :status, :inclusion => { :in => %w{passive success failure important} }
end
