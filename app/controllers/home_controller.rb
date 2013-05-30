class HomeController < ApplicationController

  before_filter :authenticate_user!
  before_filter :not_submitter!

  def index
    if Conference.count == 0
      redirect_to new_conference_path and return
    end
    if cannot? :read, Conference
      redirect_to cfp_root_path and return
    end
    @versions = Version.where(conference_id: @conference.id).includes(:item).order("created_at DESC").limit(5)
  end
end
