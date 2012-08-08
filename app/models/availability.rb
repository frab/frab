class Availability < ActiveRecord::Base

  # if several conferences were on the same day,
  # one person could have different availabilities for
  # each of them
  belongs_to :person
  belongs_to :conference
  belongs_to :day

  validate :start_date_before_end_date
  after_save :update_event_conflicts

  def self.build_for(conference)
    result = Array.new
    conference.each_day do |day|
      result << self.new(
        :day => day,
        :start_date=> day.start_date,
        :end_date=> day.end_date,
        :conference => conference
      )
    end
    result
  end

  def within_range?(time)
    if self.conference.timezone and time.zone != self.conference.timezone
      time = time.in_time_zone(self.conference.timezone)
    end
    start_minutes = time_in_minutes(self.start_date)
    end_minutes = time_in_minutes(self.end_date)
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
  
  def start_date_before_end_date
    self.errors.add(:end_date, "should be after start date") if self.end_date < self.start_date
  end

end
