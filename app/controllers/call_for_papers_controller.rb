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

  def update
    @call_for_papers = @conference.call_for_papers

    if @call_for_papers.update_attributes(params[:call_for_papers])
      redirect_to call_for_papers_path, notice: "Changes saved successfully!"
    else
      render action: "edit"
    end
  end
end
