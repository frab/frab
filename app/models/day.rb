class Day < ApplicationRecord
  include HumanizedDateRange

  belongs_to :conference
  has_many :availabilities, dependent: :destroy

  has_paper_trail meta: { associated_id: :conference_id, associated_type: 'Conference' }

  default_scope { order(start_date: :asc) }

  validates :start_date, presence: true
  validates :end_date, presence: true
  validate :start_date_before_end_date
  validate :does_not_overlap

  def start_date_before_end_date
    errors.add(:end_date, 'should be after start date') if start_date >= end_date
  end

  def does_not_overlap
    return if conference.nil?
    conference.days.each { |day|
      next if day == self
      errors.add(:start_date, "day overlapping with day #{day.label} from this conference") if start_date.between?(day.start_date, day.end_date)
      errors.add(:end_date, "day overlapping with day #{day.label} from this conference") if end_date.between?(day.start_date, day.end_date)
    }
  end

  def start_times_map
    times = []
    time = start_date
    while time <= end_date
      times << yield(time, I18n.l(time, format: :pretty_datetime))
      time = time.since(conference.timeslot_duration.minutes)
    end
    times
  end

  def start_times
    start_times_map { |_time, pretty| pretty }
  end

  def label
    start_date.strftime('%Y-%m-%d')
  end
  alias to_label label

  def date
    start_date.to_date
  end

  # ActionView::Helper.options_for_select
  def first
    label
  end

  # ActionView::Helper.options_for_select
  def last
    label
  end

  def day_index
    conference.days.index(self)
  end

  def rooms_with_events
    @rooms ||= conference.rooms_including_subs.select do |room|
      room.events.confirmed.no_conflicts.is_public.scheduled_on(self).order(:start_time).present?
    end
  end

  def to_s
    "#{model_name.human}: #{label}"
  end
end
