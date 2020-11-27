# frozen_string_literal: true
class Event < ApplicationRecord
  include ActionView::Helpers::TextHelper
  include EventState
  include HasEventConflicts

  before_create :generate_guid

  TYPES = %w(lecture workshop podium lightning_talk meeting film concert djset performance other).freeze
  ACCEPTED = %w(accepting unconfirmed confirmed scheduled).freeze

  has_one :ticket, as: :object, dependent: :destroy
  has_many :event_attachments, dependent: :destroy
  has_many :event_feedbacks, dependent: :destroy
  has_many :event_people, dependent: :destroy
  has_many :event_ratings, dependent: :destroy
  has_many :review_scores, through: :event_ratings
  has_many :average_review_scores, dependent: :destroy
  has_many :event_classifiers, dependent: :destroy
  has_many :links, as: :linkable, dependent: :destroy
  has_many :people, through: :event_people

  belongs_to :conference
  belongs_to :track, optional: true
  belongs_to :room, optional: true

  has_attached_file :logo,
    styles: { tiny: '16x16>', small: '32x32>', large: '128x128>' },
    default_url: 'event_:style.png'

  accepts_nested_attributes_for :event_people, allow_destroy: true, reject_if: proc { |attr| attr[:person_id].blank? }
  accepts_nested_attributes_for :links, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :event_attachments, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :ticket, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :event_classifiers, allow_destroy: true
  accepts_nested_attributes_for :event_ratings, allow_destroy: true
  accepts_nested_attributes_for :average_review_scores, allow_destroy: true

  validates_attachment_content_type :logo, content_type: [/jpg/, /jpeg/, /png/, /gif/]

  validates :title, :time_slots, presence: true

  scope :accepted, -> { where(arel_table[:state].in(ACCEPTED)) }
  scope :associated_with, ->(person) { joins(:event_people).where("event_people.person_id": person.id) }
  scope :candidates, -> { where(state: %w(new review accepting unconfirmed confirmed scheduled)) }
  scope :confirmed, -> { where(state: %w(confirmed scheduled)) }
  scope :is_public, -> { where(public: true) }
  scope :scheduled_on, ->(day) { where(arel_table[:start_time].gteq(day.start_date.to_datetime)).where(arel_table[:start_time].lteq(day.end_date.to_datetime)).where(arel_table[:room_id].not_eq(nil)) }
  scope :scheduled, -> { where(arel_table[:start_time].not_eq(nil).and(arel_table[:room_id].not_eq(nil))) }
  scope :unscheduled, -> { where(arel_table[:start_time].eq(nil).or(arel_table[:room_id].eq(nil))) }
  scope :without_speaker, -> { where('speaker_count = 0') }
  scope :with_speaker, -> { where('speaker_count > 0') }
  scope :with_more_than_one_speaker, -> { where('speaker_count > 1') }

  scope :with_review_averages, ->(conference) {
    e = select(column_names, conference.review_metrics.map{|rm| "#{rm.safe_name}.score AS #{rm.safe_name}"})
    conference.review_metrics.each do |rm|
      e = e.joins("LEFT OUTER JOIN average_review_scores #{rm.safe_name} ON #{rm.safe_name}.event_id=events.id AND #{rm.safe_name}.review_metric_id=#{rm.id}")
    end
    e
  }
  
  def self.ransackable_attributes(auth_object = nil)
    column_names + ReviewMetric.all.map(&:safe_name)
  end
  
  def self.ransortable_attributes(auth_object = nil)
    column_names + ReviewMetric.all.map(&:safe_name)
  end

  def self.add_ransacker(rm)
    ransacker rm.safe_name do
      Arel.sql(rm.safe_name)
    end
  end

  ReviewMetric.all.each do |rm|
    add_ransacker(rm)
  end

  has_paper_trail
  has_secure_token :invite_token

  def self.ids_by_least_reviewed(conference, reviewer)
    already_reviewed = connection.select_rows("SELECT events.id 
                                               FROM events 
                                               JOIN event_ratings ON events.id = event_ratings.event_id 
                                               WHERE events.conference_id = #{conference.id}
                                               AND   event_ratings.person_id = #{reviewer.id} 
                                               AND   event_ratings.rating IS NOT NULL 
                                               AND   event_ratings.rating <> 0").flatten.map(&:to_i)
    least_reviewed = conference.events.order(event_ratings_count: :asc).pluck(:id)
    least_reviewed -= already_reviewed
    least_reviewed
  end

  def localized_event_type(locale = nil)
    return '' unless event_type.present?
    I18n.t(event_type, scope: 'options', locale: locale, default: event_type)
  end

  def track_name
    track.try(:name)
  end

  def track_name=(name)
    update(track: conference.tracks.find_by(name: name))
  end

  def end_time
    start_time.since((time_slots * conference.timeslot_duration).minutes)
  end

  def people_involved_or_reviewing
    ids = event_ratings.pluck(:person_id) + event_people.pluck(:person_id)
    Person.where(id: ids.uniq)
  end

  def duration_in_minutes
    (time_slots * conference.timeslot_duration).minutes
  end

  def localized_duration
    ApplicationController.helpers.duration_to_time(time_slots * conference.timeslot_duration)
  end

  def feedback_standard_deviation
    arr = event_feedbacks.map(&:rating).reject(&:nil?)
    return if arr.count < 1

    n = arr.count
    m = arr.reduce(:+).to_f / n
    '%02.02f' % Math.sqrt(arr.inject(0) { |sum, item| sum + (item - m)**2 } / (n - 1))
  end

  def recalculate_average_feedback!
    update_attributes(average_feedback: average(:event_feedbacks))
  end

  def recalculate_average_rating!
    update_attributes(average_rating: average_of_nonzeros(event_ratings.pluck(:rating)), event_ratings_count: event_ratings.where.not(rating: [nil, 0]).count )
  end

  def recalculate_review_averages!
    conference.review_metrics.each do |review_metric|
      avg = average_of_nonzeros(review_scores.where(review_metric: review_metric).pluck(:score))
      average_review_scores.find_or_create_by(review_metric: review_metric).update_attributes(score: avg)
    end
  end

  def speakers
    event_people.presenter.includes(:person).all.map(&:person)
  end

  def subscribers
    event_people.subscriber.includes(:person).all.map(&:person)
  end

  def humanized_time_str
    return '' unless start_time.present?
    I18n.localize(start_time, format: :time) + I18n.t('time.time_range_seperator') + I18n.localize(end_time, format: :time)
  end

  def to_s
    "#{model_name.human}: #{title}"
  end

  def to_sortable
    title.gsub(/[^\w]/, '').upcase
  end

  def overlap?(other_event)
    return false unless other_event.start_time?
    return false unless start_time?
    return true if start_time <= other_event.start_time and other_event.start_time < end_time
    return true if other_event.start_time <= start_time and start_time < other_event.end_time
    false
  end

  def accepted?
    ACCEPTED.include?(state)
  end

  def remote_ticket?
    ticket.present? and ticket.remote_ticket_id.present?
  end

  def slug
    truncate(
      [
        conference.acronym,
        id,
        title.parameterize(separator: '_')
      ].flatten.join('-'),
      escape: false,
      length: 240,
      separator: '_',
      omission: ''
    ).to_str
  end

  def logo_path(size = :large)
    logo(size) if logo.present?
  end

  def clean_event_attributes!
    self.start_time = nil
    self.state = ''
    self.note = ''
    self.tech_rider = ''
    self
  end
  
  def date_of_submission_in_conference_tz
    created_at.in_time_zone(conference.timezone).to_date
  end
  
  def submitted_after_soft_deadline?
    return true if submitted_after_hard_deadline?
    return false unless conference.call_for_participation
    return true if date_of_submission_in_conference_tz > conference.call_for_participation&.end_date
    false
  end

  def submitted_after_hard_deadline?
    return false unless conference.call_for_participation&.hard_deadline
    return true if date_of_submission_in_conference_tz > conference.call_for_participation&.hard_deadline
    return false
  end
  
  

  private

  def generate_guid
    self.guid = SecureRandom.uuid
  end

  def average(rating_type)
    result = 0
    rating_count = 0
    send(rating_type).each do |rating|
      if rating.rating
        result += rating.rating
        rating_count += 1
      end
    end
    return nil if rating_count.zero?
    result.to_f / rating_count
  end

  def average_of_nonzeros(list)
    return nil unless list
    list=list.select{ |x| x && x>0 }
    return nil if list.empty?
    list.reduce(:+).to_f / list.size
  end
end
