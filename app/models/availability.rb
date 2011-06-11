class Availability < ActiveRecord::Base

  belongs_to :person
  belongs_to :conference

  after_save :update_event_conflicts

  def self.build_for(conference)
    result = Array.new
    conference.each_day do |date|
      result << self.new(
        :day => date,
        :start_time => "08:00:00",
        :end_time => "18:00:00",
        :conference => conference
      )
    end
    result
  end

  def time_range
    "#{self.start_time.hour}-#{self.end_time.hour}"
  end

  def time_range=(new_range) 
    unless new_range.blank?
      from, to = new_range.split("-")
      self.start_time = from
      self.end_time = to
    end
  end

  def within_range?(time)
    if self.conference.timezone and time.zone != self.conference.timezone
      time = time.in_time_zone(self.conference.timezone)
    end
    start_minutes = time_in_minutes(self.start_time)
    end_minutes = time_in_minutes(self.end_time)
    test_minutes = time_in_minutes(time)
    start_minutes <= test_minutes and end_minutes >= test_minutes
  end

  private

  def time_in_minutes(time)
    time.hour * 60 + time.min
  end

  def update_event_conflicts
    self.person.events_in(self.conference).each do |event|
      event.update_conflicts if event.start_time and event.start_time.to_date == self.day
    end
  end

end
