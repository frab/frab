class CallForPapersController < ApplicationController

  before_filter :authenticate_user!
  before_filter :not_submitter!
  load_and_authorize_resource

  def show
    @call_for_papers = @conference.call_for_papers 
  end

  def new
    @call_for_papers = CallForPapers.new
  end

  def create
    @call_for_papers = CallForPapers.new(params[:call_for_papers])
    @call_for_papers.conference = @conference

    if @call_for_papers.save
      redirect_to call_for_papers_path, notice: "Launched Call for Papers."
    else
      render action: "new"
    end
  end

  def edit
    @call_for_papers = @conference.call_for_papers
  end

  def edit_notifications
    @call_for_papers = @conference.call_for_papers
  end

  def update
    @call_for_papers = @conference.call_for_papers
    if @call_for_papers.update_attributes(params[:call_for_papers])
      redirect_to call_for_papers_path, notice: "Changes saved successfully!"
    else
      flash[:alert] = "Failed to update notifications"
      render action: "edit"
    end
  end

  def default_notifications
    locale = params[:code]

    notification = Notification.new(locale: locale)
    notification.set_default_text(locale)

    respond_to do |format|
      format.json { render json: notification.to_json }
    end
  end
end
