class TicketServer < ActiveRecord::Base
  belongs_to :conference
  validates_presence_of :url, :queue, :user, :password
  validates_format_of :url, with: /\/\z/
end
