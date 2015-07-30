class HomeController < ApplicationController

  before_filter :authenticate_user!
  before_filter :not_submitter!

  def index
    if Conference.count == 0
      return redirect_to new_conference_path
    end
    if cannot? :read, Conference
      # maybe a crew user tries to login to the wrong conference?
      if current_user.is_crew?
        conference = current_user.conference_users.map { |cu| cu.conference }.last
        return redirect_to conference_home_path(conference_acronym: conference.acronym) if conference.present?
      end
      return redirect_to cfp_root_path
    end
    @versions = PaperTrail::Version.where(conference_id: @conference.id).includes(:item).order("created_at DESC").limit(5)
  end
end
