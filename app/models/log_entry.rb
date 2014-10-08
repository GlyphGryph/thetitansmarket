class LogEntry < ActiveRecord::Base
  belongs_to :log
  validates_presence_of :log, :body, :status
  validates :status, :inclusion => { :in => %w{passive success failure important} }
end
