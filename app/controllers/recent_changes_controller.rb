class RecentChangesController < BaseConferenceController
  before_action :orga_only!

  def index
    @all_versions = PaperTrail::Version.where(conference_id: @conference.id).order('created_at DESC')
    @versions = @all_versions.paginate(
      page: page_param,
      per_page: 25
    )
    respond_to do |format|
      format.html
      format.xml { render xml: @all_versions }
      format.json { render json: @all_versions.to_json }
    end
  end

  def show
    @version = PaperTrail::Version.where(conference_id: @conference.id, id: params[:id]).first
  end
end
