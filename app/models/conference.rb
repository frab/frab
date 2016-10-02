class Conference < ActiveRecord::Base
  TICKET_TYPES = %w(otrs rt redmine integrated)

  has_many :availabilities, dependent: :destroy
  has_many :conference_users, dependent: :destroy
  has_many :days, dependent: :destroy
  has_many :events, dependent: :destroy
  has_many :languages, as: :attachable, dependent: :destroy
  has_many :notifications, dependent: :destroy
  has_many :rooms, dependent: :destroy
  has_many :tracks, dependent: :destroy
  has_many :conference_exports, dependent: :destroy
  has_many :mail_templates, dependent: :destroy
  has_many :transport_needs, dependent: :destroy
  has_many :subs, class_name: Conference, foreign_key: :parent_id
  has_one :call_for_participation, dependent: :destroy
  has_one :ticket_server, dependent: :destroy
  belongs_to :parent, class_name: Conference

  accepts_nested_attributes_for :rooms, reject_if: proc { |r| r['name'].blank? }, allow_destroy: true
  accepts_nested_attributes_for :days, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :notifications, allow_destroy: true
  accepts_nested_attributes_for :tracks, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :languages, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :ticket_server

  validates_presence_of :title,
    :acronym,
    :default_timeslots,
    :max_timeslots,
    :timeslot_duration,
    :timezone
  validates_inclusion_of :feedback_enabled, in: [true, false]
  validates_inclusion_of :expenses_enabled, in: [true, false]
  validates_inclusion_of :transport_needs_enabled, in: [true, false]
  validates_inclusion_of :bulk_notification_enabled, in: [true, false]
  validates_uniqueness_of :acronym
  validates :acronym, format: { with: /\A[a-zA-Z0-9_-]*\z/ }
  validates :color, format: { with: /\A[a-zA-Z0-9]*\z/ }
  validate :days_do_not_overlap
  validate :subs_dont_allow_days
  validate :subs_cant_have_subs

  after_update :update_timeslots

  has_paper_trail

  scope :has_submission, ->(person) {
    joins(events: [{ event_people: :person }])
      .where(EventPerson.arel_table[:event_role].in(%w(speaker moderator)))
      .where(Person.arel_table[:id].eq(person.id)).uniq
  }

  scope :creation_order, -> { order('conferences.created_at DESC') }

  scope :accessible_by_crew, ->(user) {
    joins(:conference_users).where(conference_users: { user_id: user })
  }

  scope :accessible_by_orga, ->(user) {
    joins(:conference_users).where(conference_users: { user_id: user, role: 'orga' })
  }

  alias :own_days :days

  def days
    if parent
      parent.days
    else
      own_days
    end
  end

  def timezone
    if parent
      parent.timezone
    else
      self.attributes['timezone']
    end
  end

  def timeslot_duration
    if parent
      parent.timeslot_duration
    else
      self.attributes['timeslot_duration']
    end
  end

  def include_subs
    [self, self.subs].flatten.uniq
  end

  def events_including_subs
    Event.where(conference: self.include_subs)
  end

  def rooms_including_subs
    Room.where(conference: self.include_subs)
  end

  def tracks_including_subs
    Track.where(conference: self.include_subs)
  end

  def languages_including_subs
    Language.where(attachable: self.include_subs)
  end

  def self.current
    self.order('created_at DESC').first
  end

  def submission_data
    result = {}
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
      [[0, self.events.where(state: %w(new review)).count]],
      [[1, self.events.where(state: %w(accepting unconfirmed confirmed scheduled)).count]],
      [[2, self.events.where(state: %w(rejecting rejected)).count]],
      [[3, self.events.where(state: %w(withdrawn canceled)).count]]
    ]
  end

  def events_by_state_and_type(type)
    [
      [[0, self.events.where(state: %w(new review), event_type: type).count]],
      [[1, self.events.where(state: %w(accepting unconfirmed confirmed scheduled), event_type: type).count]],
      [[2, self.events.where(state: %w(rejecting rejected), event_type: type).count]],
      [[3, self.events.where(state: %w(withdrawn canceled), event_type: type).count]]
    ]
  end

  def event_duration_sum(events)
    durations = events.accepted.map { |e| e.time_slots * self.timeslot_duration }
    duration_to_time durations.sum
  end

  def export_url
    "/#{EXPORT_PATH}/#{self.acronym}"
  end

  def conference_export(locale = 'en')
    ConferenceExport.where(conference_id: self.id, locale: locale).try(:first)
  end

  def language_breakdown(accepted_only = false)
    result = []
    if accepted_only
      base_relation = self.events.accepted
    else
      base_relation = self.events
    end
    self.languages.each do |language|
      result << { label: language.code, data: base_relation.where(language: language.code).count }
    end
    result << { label: 'unknown', 'data' => base_relation.where(language: '').count }
    result
  end

  def gender_breakdown(accepted_only = false)
    result = []
    ep = Person.joins(events: :conference)
               .where("conferences.id": self.id)
               .where("event_people.event_role": %w(speaker moderator))
               .where("events.public": true)

    ep = ep.where("events.state": %w(accepting confirmed scheduled)) if accepted_only

    ep.group(:gender).count.each do |k, v|
      k = 'unknown' if k.nil?
      result << { label: k, data: v }
    end

    result
  end

  def language_codes
    codes = self.languages.map { |l| l.code.downcase }
    codes = %w(en) if codes.empty?
    codes
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
      i += 1
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
    true
  end

  def ticket_server_enabled?
    return false if self.ticket_type.nil?
    return false if self.ticket_type == 'integrated'
    true
  end

  def to_s
    "#{model_name.human}: #{self.title} (#{self.acronym})"
  end

  private

  def update_timeslots
    return unless self.timeslot_duration_changed? and self.events.count > 0
    old_duration = self.timeslot_duration_was
    factor = old_duration / self.timeslot_duration
    Event.paper_trail.disable
    self.events_including_subs.each do |event|
      event.update_attributes(time_slots: event.time_slots * factor)
    end
    Event.paper_trail.enable
  end

  # if a conference has multiple days, they sould not overlap
  def days_do_not_overlap
    return if self.days.count < 2
    days = self.days.sort { |a, b| a.start_date <=> b.start_date }
    yesterday = days[0]
    days[1..-1].each { |day|
      if day.start_date < yesterday.end_date
        self.errors.add(:days, "day #{day} overlaps with day before")
      end
    }
  end

  def subs_dont_allow_days
    if Day.where(conference: self).any? && self.parent
      self.errors.add(:days, "are not allowed for conferences with a parent")
      self.errors.add(:parent, "may not be set for conferences with days")
    end
  end

  def subs_cant_have_subs
    if self.subs.any? && self.parent
      self.errors.add(:subs, "cannot have sub-conferences and a parent")
      self.errors.add(:parent, "may not be set for conferences with a parent")
    end
  end

  def duration_to_time(duration_in_minutes)
    minutes = sprintf('%02d', duration_in_minutes % 60)
    hours = sprintf('%02d', duration_in_minutes / 60)
    "#{hours}:#{minutes}h"
  end

end
