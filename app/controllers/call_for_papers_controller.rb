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
    @call_for_papers = CallForPapers.new(call_for_papers_params)
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
    if @call_for_papers.update_attributes(call_for_papers_params)
      redirect_to call_for_papers_path, notice: "Changes saved successfully!"
    else
      flash[:alert] = "Failed to update notifications"
      render action: "edit"
    end
  end

  def default_notifications
    locale = params[:code]
    @notification = Notification.new(locale: locale)
    @notification.set_default_text(locale)
  end

  private

  def call_for_papers_params
    params.require(:call_for_papers).permit(:start_date, :end_date, :hard_deadline, :welcome_text, :info_url, :contact_email, notifications_attributes: %i(id locale accept_subject accept_body reject_subject reject_body _destroy))
  end
end
