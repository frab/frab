class Day < ActiveRecord::Base

  belongs_to :conference

  has_paper_trail :meta => {:associated_id => :conference_id, :associated_type => "Conference"}

  default_scope order(:start_date)

  validates_presence_of :start_date, :message => "missing start date"
  validates_presence_of :end_date, :message => "missing end date"
  validate :start_date_before_end_date, :message => "failed validation"
  #validate :does_not_overlap

  def start_date_before_end_date
    return unless self.start_date && self.end_date
    self.errors.add(:end_date, "should be after start date") if self.start_date > self.end_date
  end

  def does_not_overlap
    # TODO does not overlap with any other day of this conference
    true
  end

  def to_s
    "#{self.start_date} - #{self.end_date}"
  end

end
