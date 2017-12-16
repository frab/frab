module TicketServerAdapter
  class BaseAdapter
    def initialize(server)
      @server = server
      @logger = Rails.logger
    end
  end

  def get_ticket_view_url(remote_id)
    fail t('helpers.not_implemented')
  end

  def create_remote_ticket(args = {})
    fail t('helpers.not_implemented')
  end
end
