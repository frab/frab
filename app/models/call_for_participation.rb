class CallForParticipation < ApplicationRecord
  belongs_to :conference, optional: true

  validates :start_date, :end_date, presence: true

  has_paper_trail

  def to_s
    "#{model_name.human}: #{conference.title}"
  end

  def in_the_future?
    start_date > current_date
  end

  def still_running?
    current_date <= deadline
  end
 
  def hard_deadline_over?
    return false unless hard_deadline
    current_date > hard_deadline
  end

  private

  def current_date
    Time.now.in_time_zone(conference.timezone).to_date
  end

  def deadline
    return hard_deadline if hard_deadline
    end_date
  end
end
