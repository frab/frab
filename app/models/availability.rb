class Availability < ApplicationRecord
  include HumanizedDateRange

  # if several conferences were on the same day,
  # one person could have different availabilities for
  # each of them
  belongs_to :person
  belongs_to :conference
  belongs_to :day

  validate :dates_valid?
  validate :start_date_before_end_date?
  after_save :update_event_conflicts

  def self.build_for(conference)
    result = []
    conference.each_day do |day|
      result << new(
        day: day,
        start_date: day.start_date,
        end_date: day.end_date,
        conference: conference
      )
    end
    result
  end

  def within_range?(time)
    return unless start_date and end_date
    if conference.timezone and time.zone != conference.timezone
      time = time.in_time_zone(conference.timezone)
    end
    time.between?(start_date, end_date)
  end

  private

  def update_event_conflicts
    person.events_in(conference).each do |event|
      event.update_conflicts if event.start_time and event.start_time.between?(day.start_date, day.end_date)
    end
  end

  def start_date_before_end_date?
    errors.add(:end_date, 'should be after start date') if end_date < start_date
  end

  def year_valid?(year)
    return false if year < 1990 or year > 2100
    true
  end

  def dates_valid?
    errors.add(:start_date, 'not a valid date') unless year_valid?(start_date.year)
    errors.add(:end_date, 'not a valid date') unless year_valid?(end_date.year)
  end
end
