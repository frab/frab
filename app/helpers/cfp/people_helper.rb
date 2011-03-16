module Cfp::PeopleHelper

  def cfp_hard_deadline_over?
    return false unless @conference.call_for_papers.hard_deadline
    Date.today > @conference.call_for_papers.hard_deadline
  end

end
