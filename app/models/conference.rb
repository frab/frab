class Conference < ApplicationRecord
  include ConferenceStatistics
  include SubConference
  include HasTicketServer

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
  has_many :subs, class_name: 'Conference', foreign_key: :parent_id
  has_one :call_for_participation, dependent: :destroy
  belongs_to :parent, class_name: 'Conference', optional: true

  accepts_nested_attributes_for :rooms, reject_if: proc { |r| r['name'].blank? }, allow_destroy: true
  accepts_nested_attributes_for :days, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :notifications, allow_destroy: true
  accepts_nested_attributes_for :tracks, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :languages, reject_if: :all_blank, allow_destroy: true

  validates :title,
    :acronym,
    :default_timeslots,
    :max_timeslots,
    :timeslot_duration,
    :timezone, presence: true
  validates :feedback_enabled,
    :expenses_enabled,
    :transport_needs_enabled,
    :bulk_notification_enabled, inclusion: { in: [true, false] }
  validates :acronym, uniqueness: true
  validates :acronym, format: { with: /\A[a-zA-Z0-9_-]*\z/ }
  validates :color, format: { with: /\A[a-zA-Z0-9]*\z/ }
  validate :days_do_not_overlap

  after_update :update_timeslots

  has_paper_trail

  has_attached_file :logo,
    styles: { tiny: '16x16>', small: '32x32>', large: '256x256>' },
    default_url: 'conference_:style.png'

  scope :has_submission, ->(person) {
    joins(events: [{ event_people: :person }])
      .where(EventPerson.arel_table[:event_role].in(EventPerson::SPEAKER))
      .where(Person.arel_table[:id].eq(person.id)).distinct
  }

  scope :creation_order, -> { order('conferences.created_at DESC') }

  scope :accessible_by_crew, ->(user) {
    joins(:conference_users).where(conference_users: { user_id: user })
  }

  scope :accessible_by_orga, ->(user) {
    joins(:conference_users).where(conference_users: { user_id: user, role: 'orga' })
  }

  scope :past, -> { includes(:days).where(Day.arel_table[:end_date].lt(Time.now)).order('days.start_date DESC').distinct }
  scope :future, -> { includes(:days).where(Day.arel_table[:end_date].gt(Time.now)).order('days.start_date DESC').distinct }

  self.per_page = 10

  def self.current
    return if Conference.count.zero?
    order('created_at DESC, id DESC').first
  end

  def self.accessible_by_submitter(user)
    (Conference.has_submission(user.person) | Conference.future).select(&:call_for_participation).sort_by(&:created_at)
  end

  alias own_days days

  def days
    return parent.days if sub_conference?
    own_days
  end

  def cfp_open?
    return false if call_for_participation.nil?
    return false if call_for_participation.in_the_future?
    true
  end

  def timezone
    return parent.timezone if sub_conference?
    attributes['timezone']
  end

  def timeslot_duration
    return parent.timeslot_duration if sub_conference?
    attributes['timeslot_duration']
  end

  def submission_data
    result = {}
    events = self.events.order(:created_at)
    if events.size > 1
      date = events.first.created_at.to_date
      while date <= events.last.created_at.to_date
        result[date.to_time.to_i * 1000] = 0
        date = date.since(1.day).to_date
      end
    end
    events.each do |event|
      date = event.created_at.to_date.to_time.to_i * 1000
      result[date] = 0 unless result[date]
      result[date] += 1
    end
    result.to_a.sort
  end

  def export_url
    "/#{EXPORT_PATH}/#{acronym}"
  end

  def conference_export(locale = 'en')
    ConferenceExport.where(conference_id: id, locale: locale).try(:first)
  end

  def language_codes
    codes = languages.map { |l| l.code.downcase }
    codes = %w(en) if codes.empty?
    codes
  end

  def start_times_by_day
    days.map { |day| [day.to_s, day.start_times] }
  end

  def first_day
    days.min
  end

  def last_day
    days.max
  end

  def day_at(date)
    i = 1
    days.each { |day|
      return i if date.between?(day.start_date, day.end_date)
      i += 1
    }
    # fallback to first day
    1
  end

  def each_day(&block)
    days.each(&block)
  end

  def in_the_past
    return false if days.nil? or days.empty?
    return false if Time.now < days.last.end_date
    true
  end

  def main_conference?
    parent.nil?
  end

  def sub_conference?
    parent.present?
  end

  # these events should appear in the schedule
  def schedule_events
    events_including_subs
      .includes(:track, :room)
      .is_public.confirmed
      .scheduled
  end

  def to_s
    "#{model_name.human}: #{title} (#{acronym})"
  end

  private

  def update_timeslots
    return unless saved_change_to_timeslot_duration? and events.count.positive?
    old_duration = timeslot_duration_before_last_save
    factor = old_duration / timeslot_duration
    Event.paper_trail.disable
    events_including_subs.each do |event|
      event.update_attributes(time_slots: event.time_slots * factor)
    end
    Event.paper_trail.enable
  end

  # if a conference has multiple days, they sould not overlap
  def days_do_not_overlap
    return if days.count < 2
    days = self.days.sort_by(&:start_date)
    yesterday = days[0]
    days[1..-1].each { |day|
      if day.start_date < yesterday.end_date
        errors.add(:days, "day #{day} overlaps with day before")
      end
    }
  end
end
