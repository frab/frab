class TicketServer < ActiveRecord::Base
  belongs_to :conference
  validates_presence_of :url, :queue
  validates_format_of :url, :with => /\/$/
end
