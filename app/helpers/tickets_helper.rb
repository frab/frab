module TicketsHelper
  def get_ticket_view_url(remote_id = 0)
    return if @conference.nil?
    return if @conference.ticket_server.nil?
    @conference.ticket_server.get_ticket_view_url(remote_id)
  end

  private

  def is_a_number(test)
    Integer(test)
    true
  rescue
    false
  end
end
