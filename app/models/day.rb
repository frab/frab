class Day < ActiveRecord::Base

  belongs_to :conference
  # TODO a new day should search matching availabilities without a day:
  #      in case someone deletes a day, availabilities need to persist,
  #      so they can be reclaimed by a new day later
  #      if a.day_id.nil?
  #      a.day_id = Conference.all.days.map { |day| day.id 
  #        if a.start_time.between?(day.start_date, day.end_date)
  #           or a.end_time.between?(day.start_date, day.end_date)
  #           or day.start_date.between?(a.start_time, a.end_time) }
  has_many :availabilities

  has_paper_trail :meta => {:associated_id => :conference_id, :associated_type => "Conference"}

  default_scope order(:start_date)

  validates_presence_of :start_date, :message => "missing start date"
  validates_presence_of :end_date, :message => "missing end date"
  validate :start_date_before_end_date, :message => "failed validation"
  validate :does_not_overlap

  def start_date_before_end_date
    return unless self.start_date && self.end_date
    self.errors.add(:end_date, "should be after start date") if self.start_date >= self.end_date
  end

  def does_not_overlap
    # TODO does not overlap with any other day of this conference
    true
  end

  def name
    self.start_date.strftime('%Y-%m-%d')
  end

  # def uniq_name
  #   # enforced?
  #   self.start_date.strftime('%Y-%m-%d %H:%M')
  # end

  def to_s
    "#{self.start_date} - #{self.end_date}"
  end

end
