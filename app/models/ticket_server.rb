class TicketServer < ActiveRecord::Base
  belongs_to :conference
  validates_presence_of :url, :queue, :user, :password
  validates_format_of :url, with: /\/\z/

  def adapter
    type = self.conference.ticket_type.to_sym

    if type == :otrs
      OTRSTicketServerAdapter.new(self)
    elsif type == :redmine
      RedmineTicketServerAdapter.new(self)
    else
      RTTicketServerAdapter.new(self)
    end
  end

  def get_ticket_view_url(remote_id)
    adapter.get_ticket_view_url(remote_id)
  end

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
