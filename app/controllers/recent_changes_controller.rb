class RecentChangesController < ApplicationController
  before_action :authenticate_user!
  before_action :not_submitter!

  def index
    authorize! :manage, CallForParticipation
    @all_versions = PaperTrail::Version.where(conference_id: @conference.id).order("created_at DESC")
    @versions = @all_versions.paginate(
      page: page_param,
      per_page: 25
    )
    respond_to do |format|
      format.html
      format.xml { render xml: @all_versions }
    end
  end

  def show
    authorize! :manage, CallForParticipation
    @version = PaperTrail::Version.where(conference_id: @conference.id, id: params[:id]).first
  end
end
