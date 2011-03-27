class Availability < ActiveRecord::Base

  belongs_to :person
  belongs_to :conference

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

end
