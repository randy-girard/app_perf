class Deployment < ::Event
  attr_accessor :event_time

  validates :title, :presence => true
  validates :start_time, :presence => true
  validates :end_time, :presence => true

  def event_time=(et)
    self.start_time = et
    self.end_time = et
  end

  def event_time
    self.start_time
  end
end
