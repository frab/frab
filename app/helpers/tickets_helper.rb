module TicketsHelper
  def get_ticket_view_url(remote_id = '0')
    return if @conference.nil?
    if @conference.ticket_type == 'otrs'
      if is_a_number(remote_id)
        OtrsTickets::Helper.get_ticket_view_url(@conference, remote_id.to_i)
      end
    elsif @conference.ticket_type == 'rt'
      RTTickets::Helper.get_ticket_view_url(@conference, remote_id)
    end
  end

  private

  def is_a_number(test)
    Integer(test)
    true
  rescue
    false
  end
end
