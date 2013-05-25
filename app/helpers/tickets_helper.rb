module TicketsHelper
  def get_ticket_view_url( remote_id='0' )
    return if @conference.nil?
    if @conference.ticket_type == 'otrs'
      OtrsTickets::Helper.get_ticket_view_url(@conference, remote_id)
    elsif @conference.ticket_type == 'rt'
      RTTickets::Helper.get_ticket_view_url(remote_id)
    end
  end
end
