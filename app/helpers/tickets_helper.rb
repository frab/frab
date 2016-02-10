module TicketsHelper
  def get_ticket_view_url(remote_id = '0')
    return if @conference.nil?

    ticket_module = @conference.get_ticket_module
    ticket_module::Helper.get_ticket_view_url @conference, remote_id
  end

  private

  def is_a_number(test)
    Integer(test)
    true
  rescue
    false
  end
end
