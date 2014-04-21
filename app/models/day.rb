class Day < ActiveRecord::Base
  include HumanizedDateRange

  belongs_to :conference
  # TODO a new day should search matching availabilities without a day:
  #      in case someone deletes a day, availabilities need to persist,
  #      so they can be reclaimed by a new day later
  #      if a.day_id.nil?
  #      on_create(day)
  #      conference.availabilities.each { |a| 
  #      next unless a.day_id = nil
  #      a.day_id = @conference.days.map { |day| day.id 
  #        if a.start_time.between?(day.start_date, day.end_date)
  #           or a.end_time.between?(day.start_date, day.end_date)
  #           or day.start_date.between?(a.start_time, a.end_time) }
  has_many :availabilities

  has_paper_trail meta: {associated_id: :conference_id, associated_type: "Conference"}

  default_scope { order(start_date: :asc) }

  validates_presence_of :start_date, message: "missing start date"
  validates_presence_of :end_date, message: "missing end date"
  validate :start_date_before_end_date, message: "failed validation"
  validate :does_not_overlap, message: "overlaps, failed validation"

  def start_date_before_end_date
    self.errors.add(:end_date, "should be after start date") if self.start_date >= self.end_date
  end

  def does_not_overlap
    return if self.conference.nil?
    self.conference.days.each { |day|
      next if day == self
      self.errors.add(:start_date, "day overlapping with day #{day.label} from this conference") if self.start_date.between?(day.start_date, day.end_date)
      self.errors.add(:end_date, "day overlapping with day #{day.label} from this conference") if self.end_date.between?(day.start_date, day.end_date)
    }
  end

  def label
    self.start_date.strftime('%Y-%m-%d')
  end

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
    "Day: #{self.label}"
  end

end
