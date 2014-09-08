module Cfp::EventsHelper
  def deny_accepted(event)
    accepted = event.accepted?
    { readonly: accepted, disabled: accepted }
  end
end
