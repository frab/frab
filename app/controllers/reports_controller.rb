class ReportsController < ApplicationController

  before_filter :authenticate_user!
  before_filter :require_admin

  def index
  end

  def show_people
    @id = params[:id]
    @people = []

    if @report_id
      @search = Person.search(params[:q])
      @people = @search.result.paginate :page => params[:page]
    end
    render :show
  end

  def show_events
    @report_id = params[:id]
    @events = []

    if @report_id
      @search = @conference.events.search(params[:q])
      @events = @search.result.paginate :page => params[:page]
    end
    render :show
  end

end
