class Day < ActiveRecord::Base
  belongs_to :conference
  validates_presence_of :start_date
  validates_presence_of :end_date
end
