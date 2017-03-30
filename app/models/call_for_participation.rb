class CallForParticipation < ApplicationRecord
  belongs_to :conference

  validates :start_date, :end_date, presence: true

  has_paper_trail

  def to_s
    "#{model_name.human}: #{conference.title}"
  end
end
