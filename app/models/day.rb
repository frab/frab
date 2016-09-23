class Day < ActiveRecord::Base
  include HumanizedDateRange

  belongs_to :conference
  has_many :availabilities

  has_paper_trail meta: { associated_id: :conference_id, associated_type: 'Conference' }

  default_scope { order(start_date: :asc) }

  validates :start_date, presence: true
  validates :end_date, presence: true
  validate :start_date_before_end_date
  validate :does_not_overlap

  def start_date_before_end_date
    self.errors.add(:end_date, 'should be after start date') if self.start_date >= self.end_date
  end

  def does_not_overlap
    return if self.conference.nil?
    self.conference.days.each { |day|
      next if day == self
      self.errors.add(:start_date, "day overlapping with day #{day.label} from this conference") if self.start_date.between?(day.start_date, day.end_date)
      self.errors.add(:end_date, "day overlapping with day #{day.label} from this conference") if self.end_date.between?(day.start_date, day.end_date)
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
    start_times_map { |time, pretty| pretty }
  end

  def label
    self.start_date.strftime('%Y-%m-%d')
  end
  alias_method :to_label, :label

  def date
    self.start_date.to_date
  end

  # ActionView::Helper.options_for_select
  def first
    self.label
  end

  # ActionView::Helper.options_for_select
  def last
    self.label
  end

  def to_s
    "#{model_name.human}: #{self.label}"
  end
end
