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

  def update
    @call_for_papers = @conference.call_for_papers
    if @call_for_papers.update_attributes(call_for_papers_params)
      redirect_to call_for_papers_path, notice: "Changes saved successfully!"
    else
      flash[:alert] = "Failed to update"
      render action: "edit"
    end
  end

  private

  def call_for_papers_params
    params.require(:call_for_papers).permit(:start_date, :end_date, :hard_deadline, :welcome_text, :info_url, :contact_email)
  end
end
