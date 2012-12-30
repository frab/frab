class Conference < ActiveRecord::Base

  has_one :call_for_papers, :dependent => :destroy
  has_one :ticket_server, :dependent => :destroy
  has_many :events, :dependent => :destroy
  has_many :days, :dependent => :destroy
  has_many :rooms, :dependent => :destroy
  has_many :tracks, :dependent => :destroy
  has_many :languages, :as => :attachable, :dependent => :destroy

  accepts_nested_attributes_for :rooms, :reject_if => proc {|r| r["name"].blank?}, :allow_destroy => true
  accepts_nested_attributes_for :days, :reject_if => :all_blank, :allow_destroy => true
  accepts_nested_attributes_for :tracks, :reject_if => :all_blank, :allow_destroy => true
  accepts_nested_attributes_for :languages, :reject_if => :all_blank, :allow_destroy => true
  accepts_nested_attributes_for :ticket_server
  validates_presence_of :title, 
    :acronym, 
    :default_timeslots,
    :feedback_enabled,
    :max_timeslots,
    :timeslot_duration,
    :timezone
  validates_uniqueness_of :acronym
  validates_format_of :acronym, :with => /^[a-zA-Z0-9_-]*$/
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
      [[0, self.events.where(:state => ["new", "review"]).count]],
      [[1, self.events.where(:state => ["unconfirmed", "confirmed"]).count]],
      [[2, self.events.where(:state => "rejected").count]],
      [[3, self.events.where(:state => ["withdrawn", "canceled"]).count]]
    ]
  end

  def events_by_state_and_type(type)
    [
      [[0, self.events.where(:state => ["new", "review"], :event_type => type).count]],
      [[1, self.events.where(:state => ["unconfirmed", "confirmed"], :event_type => type).count]],
      [[2, self.events.where(:state => "rejected", :event_type => type).count]],
      [[3, self.events.where(:state => ["withdrawn", "canceled"], :event_type => type).count]]
    ]
  end

  def language_breakdown(accepted_only = false)
    result = Array.new
    if accepted_only
      base_relation = self.events.accepted
    else
      base_relation = self.events
    end
    self.languages.each do |language|
      result << { :label => language.code, :data => base_relation.where(:language => language.code).count }
    end
    result << {:label => "unknown", "data" => base_relation.where(:language => "").count }
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
        event.update_attributes(:time_slots => event.time_slots * factor)
      end
      Event.paper_trail_on
    end
  end

  # if a conference has multiple days, they sould not overlap
  def days_do_not_overlap
    return if self.days.count < 2
    yesterday = self.days[0]
    self.days[1..-1].each { |day|
      if day.start_date < yesterday.end_date
        self.errors.add(:days, "day #{day} overlaps with day before") 
      end
    }
  end

end
