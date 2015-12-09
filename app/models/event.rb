class Event < ActiveRecord::Base
  include ActiveRecord::Transitions
  include ActionView::Helpers::TextHelper

  before_create :generate_guid

  TYPES = [:lecture, :workshop, :podium, :lightning_talk, :meeting, :film, :concert, :djset, :performance, :other]

  has_one :ticket, dependent: :destroy
  has_many :conflicts_as_conflicting, class_name: "Conflict", foreign_key: "conflicting_event_id", dependent: :destroy
  has_many :conflicts, dependent: :destroy
  has_many :event_attachments, dependent: :destroy
  has_many :event_feedbacks, dependent: :destroy
  has_many :event_people, dependent: :destroy
  has_many :event_ratings, dependent: :destroy
  has_many :links, as: :linkable, dependent: :destroy
  has_many :people, through: :event_people
  has_many :videos, dependent: :destroy

  belongs_to :conference
  belongs_to :track
  belongs_to :room

  has_attached_file :logo,
    styles: { tiny: "16x16>", small: "32x32>", large: "128x128>" },
    default_url: "event_:style.png"

  accepts_nested_attributes_for :event_people, allow_destroy: true, reject_if: proc { |attr| attr[:person_id].blank? }
  accepts_nested_attributes_for :links, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :event_attachments, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :ticket, allow_destroy: true, reject_if: :all_blank

  validates_attachment_content_type :logo, content_type: [/jpg/, /jpeg/, /png/, /gif/]

  validates_presence_of :title, :time_slots

  after_save :update_conflicts

  scope :accepted, -> { where(self.arel_table[:state].in(%w(confirmed unconfirmed))) }
  scope :associated_with, ->(person) { joins(:event_people).where(:"event_people.person_id" => person.id) }
  scope :candidates, -> { where(state: %w(new review unconfirmed confirmed)) }
  scope :confirmed, -> { where(state: :confirmed) }
  scope :no_conflicts, -> { includes(:conflicts).where(:"conflicts.event_id" => nil) }
  scope :is_public, -> { where(public: true) }
  scope :scheduled_on, ->(day) { where(self.arel_table[:start_time].gteq(day.start_date.to_datetime)).where(self.arel_table[:start_time].lteq(day.end_date.to_datetime)).where(self.arel_table[:room_id].not_eq(nil)) }
  scope :scheduled, -> { where(self.arel_table[:start_time].not_eq(nil).and(self.arel_table[:room_id].not_eq(nil))) }
  scope :unscheduled, -> { where(self.arel_table[:start_time].eq(nil).or(self.arel_table[:room_id].eq(nil))) }
  scope :without_speaker, -> { where("speaker_count = 0") }
  scope :with_speaker, -> { where("speaker_count > 0") }

  has_paper_trail

  state_machine do
    state :new
    state :review
    state :withdrawn
    state :unconfirmed
    state :confirmed
    state :canceled
    state :rejected

    event :start_review do
      transitions to: :review, from: :new
    end
    event :withdraw do
      transitions to: :withdrawn, from: [:new, :review, :unconfirmed]
    end
    event :accept do
      transitions to: :unconfirmed, from: [:new, :review], on_transition: :process_acceptance
    end
    event :confirm do
      transitions to: :confirmed, from: :unconfirmed
    end
    event :cancel do
      transitions to: :canceled, from: [:unconfirmed, :confirmed]
    end
    event :reject do
      transitions to: :rejected, from: [:new, :review], on_transition: :process_rejection
    end
  end

  def self.ids_by_least_reviewed(conference, reviewer)
    # FIXME native SQL
    already_reviewed = self.connection.select_rows("SELECT events.id FROM events JOIN event_ratings ON events.id = event_ratings.event_id WHERE events.conference_id = #{conference.id} AND event_ratings.person_id = #{reviewer.id}").flatten.map(&:to_i)
    least_reviewed = self.connection.select_rows("SELECT events.id FROM events LEFT OUTER JOIN event_ratings ON events.id = event_ratings.event_id WHERE events.conference_id = #{conference.id} GROUP BY events.id ORDER BY COUNT(event_ratings.id) ASC, events.id ASC").flatten.map(&:to_i)
    least_reviewed -= already_reviewed
    least_reviewed
  end

  def track_name
    self.track.try(:name)
  end

  def end_time
    self.start_time.since((self.time_slots * self.conference.timeslot_duration).minutes)
  end

  def transition_possible?(transition)
    self.class.state_machine.events_for(self.current_state).include?(transition)
  end

  def feedback_standard_deviation
    arr = self.event_feedbacks.map(&:rating).reject(&:nil?)
    return if arr.count < 1

    n = arr.count
    m = arr.reduce(:+).to_f / n
    "%02.02f" % Math.sqrt(arr.inject(0) { |sum, item| sum + (item - m)**2 } / (n - 1))
  end

  def recalculate_average_feedback!
    self.update_attributes(average_feedback: average(:event_feedbacks))
  end

  def recalculate_average_rating!
    self.update_attributes(average_rating: average(:event_ratings))
  end

  def speakers
    self.event_people.presenter.includes(:person).all.map(&:person)
  end

  def humanized_time_str
    return "" unless start_time.present?
    I18n.localize(start_time, format: :time) + I18n.t('time.time_range_seperator') + I18n.localize(end_time, format: :time)
  end

  def to_s
    "Event: #{self.title}"
  end

  def to_sortable
    self.title.gsub(/[^\w]/, '').upcase
  end

  def process_acceptance(options)
    if options[:send_mail]
      self.event_people.presenter.each do |event_person|
        event_person.generate_token!
        SelectionNotification.acceptance_notification(event_person).deliver_now
      end
    end
    return unless options[:coordinator]
    return if self.event_people.find_by_person_id_and_event_role(options[:coordinator].id, "coordinator")
    self.event_people.create(person: options[:coordinator], event_role: "coordinator")
  end

  def process_rejection(options)
    if options[:send_mail]
      self.event_people.presenter.each do |event_person|
        SelectionNotification.rejection_notification(event_person).deliver_now
      end
    end
    return unless options[:coordinator]
    return if self.event_people.find_by_person_id_and_event_role(options[:coordinator].id, "coordinator")
    self.event_people.create(person: options[:coordinator], event_role: "coordinator")
  end

  def overlap?(other_event)
    if self.start_time <= other_event.start_time and other_event.start_time < self.end_time
      true
    elsif other_event.start_time <= self.start_time and self.start_time < other_event.end_time
      true
    else
      false
    end
  end

  def accepted?
    self.state == "unconfirmed" or self.state == "confirmed"
  end

  def remote_ticket?
    ticket.present? and ticket.remote_ticket_id.present?
  end

  def update_conflicts
    self.conflicts.delete_all
    self.conflicts_as_conflicting.delete_all
    if self.accepted? and self.room and self.start_time and self.time_slots
      update_event_conflicts
      update_people_conflicts
    end
    self.conflicts
  end

  def conflict_level
    return "fatal" if self.conflicts.any? { |c| c.severity == "fatal" }
    return "warning" if self.conflicts.any? { |c| c.severity == "warning" }
    nil
  end

  def update_attributes_and_return_affected_ids(attributes)
    affected_event_ids = self.conflicts.map(&:conflicting_event_id)
    self.update_attributes(attributes)
    self.reload
    affected_event_ids += self.conflicts.map(&:conflicting_event_id)
    affected_event_ids.delete(nil)
    affected_event_ids << self.id
    affected_event_ids.uniq
  end

  def slug
    truncate(
      [
        self.conference.acronym,
        self.id,
        self.title.parameterize("_")
      ].flatten.join("-"),
      escape: false,
      length: 240,
      separator: "_",
      omission: ""
    ).to_str
  end

  def static_url
    File.join self.conference.program_export_base_url, "events/#{self.id}.html"
  end

  def logo_path(size = :medium)
    self.logo(size) if self.logo.present?
  end

  def clean_event_attributes!
    self.start_time = nil
    self.state = ''
    self.note = ''
    self.tech_rider = ''
    self
  end

  private

  def generate_guid
    self.guid = SecureRandom.uuid
  end

  def average(rating_type)
    result = 0
    rating_count = 0
    self.send(rating_type).each do |rating|
      if rating.rating
        result += rating.rating
        rating_count += 1
      end
    end
    if rating_count == 0
      return nil
    else
      return result.to_f / rating_count
    end
  end

  # check if room has been assigned multiple times for the same slot
  def update_event_conflicts
    conflicting_event_candidates = self.class.accepted.where(room_id: self.room.id).where(self.class.arel_table[:start_time].gteq(self.start_time.beginning_of_day)).where(self.class.arel_table[:start_time].lteq(self.start_time.end_of_day)).where(self.class.arel_table[:id].not_eq(self.id))
    conflicting_event_candidates.each do |conflicting_event|
      if self.overlap?(conflicting_event)
        Conflict.create(event: self, conflicting_event: conflicting_event, conflict_type: "events_overlap", severity: "fatal")
        Conflict.create(event: conflicting_event, conflicting_event: self, conflict_type: "events_overlap", severity: "fatal")
      end
    end
  end

  # check wether person has availability and is available at scheduled time
  def update_people_conflicts
    self.event_people.presenter.group(:person_id, :id).each do |event_person|
      next if conflict_person_has_no_availabilities(event_person)
      conflict_person_not_available(event_person)
    end
  end

  def conflict_person_has_no_availabilities(event_person)
    return if event_person.person.availabilities.present?
    Conflict.create(event: self, person: event_person.person, conflict_type: "person_has_no_availability", severity: "warning")
  end

  def conflict_person_not_available(event_person)
    return if event_person.available_between?(self.start_time, self.end_time)
    Conflict.create(event: self, person: event_person.person, conflict_type: "person_unavailable", severity: "warning")
  end
end
