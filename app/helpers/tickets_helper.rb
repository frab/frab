module TicketsHelper
  if Rails.configuration.ticket_server_type == 'otrs_ticket'
    include OtrsTickets::Helper
  else
    include RTTickets::Helper
  end
end
