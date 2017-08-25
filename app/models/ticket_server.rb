class TicketServer < ApplicationRecord
  belongs_to :conference
  validates :url, :queue, :user, :password, presence: true
  validates :url, format: { with: /\/\z/ }

  def adapter
    type = conference.ticket_type.to_sym

    if type == :otrs
      TicketServerAdapter::OTRSAdapter.new(self)
    elsif type == :redmine
      TicketServerAdapter::RedmineAdapter.new(self)
    else
      TicketServerAdapter::RTAdapter.new(self)
    end
  end

  delegate :get_ticket_view_url, to: :adapter

  def create_remote_ticket(args = {})
    adapter.create_remote_ticket(args)
  end

  def create_ticket_requestors(people)
    people.collect { |p|
      name = "#{p.first_name} #{p.last_name}"
      name.delete!(',')
      { name: name, email: p.email }
    }
  end

  def add_correspondence(remote_id, subject, body, recipient = nil)
    adapter.add_correspondence(remote_id, subject, body, recipient)
  end
end
