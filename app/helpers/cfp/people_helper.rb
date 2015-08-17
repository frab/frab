module Cfp::PeopleHelper
  def cfp_hard_deadline_over?
    return false unless @conference.call_for_participation.hard_deadline
    Date.today > @conference.call_for_participation.hard_deadline
  end
end
