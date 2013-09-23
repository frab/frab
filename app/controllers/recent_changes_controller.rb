class RecentChangesController < ApplicationController

  before_filter :authenticate_user!
  before_filter :not_submitter!

  def index
    authorize! :manage, CallForPapers
    @versions = Version.where(conference_id: @conference.id).order("created_at DESC").paginate(
      page: params[:page],
      per_page: 25
    )
  end

  def show
    authorize! :manage, CallForPapers
    @version = Version.where(conference_id: @conference.id, id: params[:id]).first
  end

end
