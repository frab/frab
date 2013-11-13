class RecentChangesController < ApplicationController

  before_filter :authenticate_user!
  before_filter :not_submitter!

  def index
    authorize! :manage, CallForPapers
    @all_versions = Version.where(conference_id: @conference.id).order("created_at DESC")
    @versions = @all_versions.paginate(
      page: params[:page],
      per_page: 25
    )
    respond_to do |format|
      format.html
      format.xml  { render xml: @all_versions }
    end
  end

  def show
    authorize! :manage, CallForPapers
    @version = Version.where(conference_id: @conference.id, id: params[:id]).first
  end

end
