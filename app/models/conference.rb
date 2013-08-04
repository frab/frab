class Conference < ActiveRecord::Base

  TICKET_TYPES = ["otrs", "rt", "integrated"]

  has_one :call_for_papers, dependent: :destroy
  has_one :ticket_server, dependent: :destroy
  has_many :events, dependent: :destroy
  has_many :days, dependent: :destroy
  has_many :rooms, dependent: :destroy
  has_many :tracks, dependent: :destroy
  has_many :availabilities, dependent: :destroy
  has_many :languages, as: :attachable, dependent: :destroy

  acts_as_indexed fields: [:title, :acronym ]

  accepts_nested_attributes_for :rooms, reject_if: proc {|r| r["name"].blank?}, allow_destroy: true
  accepts_nested_attributes_for :days, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :tracks, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :languages, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :ticket_server
  validates_presence_of :title, 
    :acronym, 
    :default_timeslots,
    :max_timeslots,
    :timeslot_duration,
    :timezone
  validates_inclusion_of :feedback_enabled, :in => [true, false]
  validates_uniqueness_of :acronym
  validates_format_of :acronym, with: /^[a-zA-Z0-9_-]*$/
  validate :days_do_not_overlap

  after_update :update_timeslots

  has_paper_trail 

  def self.current
    self.order("created_at DESC").first
  end

  def submission_data
    result = Hash.new
    events = self.events.order(:created_at)
    if events.size > 1
      date = events.first.created_at.to_date
      while date <= events.last.created_at.to_date
        result[date.to_time.to_i * 1000] = 0
        date = date.since(1.days).to_date
      end
    end
    events.each do |event|
      date = event.created_at.to_date.to_time.to_i * 1000
      result[date] = 0 unless result[date]
      result[date] += 1
    end
    result.to_a.sort
  end

  def events_by_state
    [
      [[0, self.events.where(state: ["new", "review"]).count]],
      [[1, self.events.where(state: ["unconfirmed", "confirmed"]).count]],
      [[2, self.events.where(state: "rejected").count]],
      [[3, self.events.where(state: ["withdrawn", "canceled"]).count]]
    ]
  end

  def events_by_state_and_type(type)
    [
      [[0, self.events.where(state: ["new", "review"], event_type: type).count]],
      [[1, self.events.where(state: ["unconfirmed", "confirmed"], event_type: type).count]],
      [[2, self.events.where(state: "rejected", event_type: type).count]],
      [[3, self.events.where(state: ["withdrawn", "canceled"], event_type: type).count]]
    ]
  end

  def event_duration_sum(events)
     durations = events.accepted.map { |e| e.time_slots * self.timeslot_duration }
     duration_to_time durations.sum
  end

  def export_url
    "/#{EXPORT_PATH}/#{self.acronym}"
  end

  def language_breakdown(accepted_only = false)
    result = Array.new
    if accepted_only
      base_relation = self.events.accepted
    else
      base_relation = self.events
    end
    self.languages.each do |language|
      result << { label: language.code, data: base_relation.where(language: language.code).count }
    end
    result << {label: "unknown", "data" => base_relation.where(language: "").count }
    result
  end

  def language_codes
    self.languages.map{|l| l.code.downcase}
  end

  def first_day
    self.days.min
  end

  def last_day
    self.days.max
  end

  def day_at(date)
    i = 0
    self.days.each { |day|
      return i if date.between?(day.start_date, day.end_date)
      i = i + 1
    }
    # fallback to day at index 0
    0
  end

  def each_day(&block)
    self.days.each(&block)
  end

  def in_the_past
    return false if self.days.nil? or self.days.empty?
    return false if Time.now < self.days.last.end_date
    return true
  end

  def is_ticket_server_enabled?
    return false if self.ticket_type.nil?
    return false if self.ticket_type == 'integrated'
    return true
  end

  def get_ticket_module
    if self.ticket_type == 'otrs'
      return OtrsTickets
    else
      return RTTickets
    end
  end

  def to_s
    "Conference: #{self.title} (#{self.acronym})"
  end

  private

  def update_timeslots
    if self.timeslot_duration_changed? and self.events.count > 0
      old_duration = self.timeslot_duration_was
      factor = old_duration / self.timeslot_duration
      Event.paper_trail_off
      self.events.each do |event|
        event.update_attributes(time_slots: event.time_slots * factor)
      end
      Event.paper_trail_on
    end
  end

  # if a conference has multiple days, they sould not overlap
  def days_do_not_overlap
    return if self.days.count < 2
    days = self.days.sort { |a,b| a.start_date <=> b.start_date }
    yesterday = days[0]
    days[1..-1].each { |day|
      if day.start_date < yesterday.end_date
        self.errors.add(:days, "day #{day} overlaps with day before") 
      end
    }
  end

  def duration_to_time(duration_in_minutes)
    minutes = sprintf("%02d", duration_in_minutes % 60)
    hours = sprintf("%02d", duration_in_minutes / 60)
    "#{hours}:#{minutes}h"
  end

end
