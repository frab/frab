class Conference < ApplicationRecord
  include ConferenceStatistics
  include SubConference
  include HasTicketServer

  has_many :availabilities, dependent: :destroy
  has_many :classifiers, dependent: :destroy
  has_many :review_metrics, dependent: :destroy
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
  accepts_nested_attributes_for :classifiers, reject_if: proc { |r| r['name'].blank? }, allow_destroy: true
  accepts_nested_attributes_for :review_metrics, reject_if: proc { |r| r['name'].blank? }, allow_destroy: true
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
  validates :attachment_title_is_freeform,
    :feedback_enabled,
    :expenses_enabled,
    :transport_needs_enabled,
    :bulk_notification_enabled, inclusion: { in: [true, false] }
  validates :allowed_event_types_as_list, presence: { message: :blank }, format: { without: /\|/ }
  validates :acronym, uniqueness: true
  validates :acronym, format: { with: /\A[a-z0-9_-]*\z/ }
  validates :color, format: { with: /\A[a-zA-Z0-9]*\z/ }
  validate :days_do_not_overlap
  validate :default_timeslot_must_not_exceed_max_timeslot

  after_update :update_timeslots

  has_paper_trail

  has_attached_file :logo,
    styles: { tiny: '16x16>', small: '32x32>', large: '256x256>' },
    default_url: 'conference_:style.png'

  scope :has_submission, ->(person) {
    joins(events: [{ event_people: :person }])
      .where(EventPerson.arel_table[:event_role].in(EventPerson::SUBSCRIBERS))
      .where(Person.arel_table[:id].eq(person.id)).distinct
  }

  scope :creation_order, -> { order('conferences.created_at DESC') }

  scope :accessible_by_crew, ->(user) {
    joins(:conference_users).where(conference_users: { user_id: user })
  }

  scope :accessible_by_orga, ->(user) {
    joins(:conference_users).where(conference_users: { user_id: user, role: 'orga' })
  }

  scope :past, -> { where(Conference.arel_table[:end_date].lt(Time.now)).order('start_date DESC') }
  scope :future, -> { where(Conference.arel_table[:end_date].gt(Time.now)).order('start_date DESC') }

  self.per_page = 10

  def self.current
    return if Conference.count.zero?
    order('created_at DESC, id DESC').first
  end

  def self.accessible_by_submitter(user)
    (Conference.has_submission(user.person) | Conference.future).select(&:call_for_participation).sort_by(&:created_at)
  end

  def days
    return parent.days if sub_conference?
    super
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
  
  def allowed_event_types_presets
    Event::TYPES & allowed_event_types_as_list
  end
  
  def allowed_event_types_presets=(list)
     unchanged_extras = allowed_event_types_as_list - Event::TYPES
     new_presets = list & Event::TYPES
     update_attributes(allowed_event_types_as_list: unchanged_extras + new_presets)
  end

  def allowed_event_types_extras
    (allowed_event_types_as_list - Event::TYPES).join(';')
  end
  
  def allowed_event_types_extras=(s)
     new_extras = s.split(';').map(&:strip) - Event::TYPES
     unchanged_presets = allowed_event_types_as_list & Event::TYPES
     update_attributes(allowed_event_types_as_list: new_extras + unchanged_presets)
  end
  
  def allowed_event_types_as_list
    (allowed_event_types || '').split(';').map(&:strip)
  end
  
  def allowed_event_types_as_list=(list)
    update_attributes(allowed_event_types: list.reject(&:empty?).sort.uniq.join(';'))
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

  def in_the_past?
    return false if days.nil? or days.empty?
    return false if Time.now.in_time_zone(timezone) < days.last.end_date
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

  def events_with_review_averages
    events.with_review_averages(self)
  end

  def to_s
    "#{model_name.human}: #{title} (#{acronym})"
  end

  def to_label
    acronym
  end
  
  def allowed_event_timeslots
    return parent.allowed_event_timeslots if sub_conference?
    (allowed_event_timeslots_csv || '').split(',').map(&:to_i)
  end

  def allowed_event_timeslots=(list)
    csv=list.to_set.sort.join(',')
    update_attributes(allowed_event_timeslots_csv: csv)
  end
  
  def allowed_durations_minutes
    return [] if timeslot_duration.blank?
    allowed_event_timeslots.map{|ts| ts*timeslot_duration}
  end
  
  def allowed_durations_minutes_csv
    allowed_durations_minutes.join(',')
  end

  def allowed_durations_minutes_csv=(csv)
    return if default_timeslots.blank? or timeslot_duration.blank? or max_timeslots.blank?
    list = csv.split(',').map(&:to_i)
    timeslots=(1..max_timeslots).select{|ts| (ts*timeslot_duration).in?(list)} << default_timeslots
    update_attributes(allowed_event_timeslots: timeslots)
  end

  private
  
  def update_timeslots
    return unless saved_change_to_timeslot_duration? and events.count.positive?
    old_duration = timeslot_duration_before_last_save
    factor = old_duration / timeslot_duration
    PaperTrail.request.disable_model(Event)
    events_including_subs.each do |event|
      event.update_attributes(time_slots: event.time_slots * factor)
    end
    PaperTrail.request.enable_model(Event)
  end

  # if a conference has multiple days, they should not overlap
  def days_do_not_overlap
    return if days.count < 2
    days.each{ |day| day.does_not_overlap }
  end
  
  def default_timeslot_must_not_exceed_max_timeslot
    return if default_timeslots.blank? or max_timeslots.blank?
    if default_timeslots > max_timeslots
      errors.add(:default_timeslots, :exceeds, what: I18n.t('activerecord.attributes.conference.max_timeslots'))
    end
  end
end
