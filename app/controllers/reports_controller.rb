class ReportsController < ApplicationController

  before_filter :authenticate_user!
  before_filter :require_admin

  def index
  end

  def show_events
    @report_type = params[:id]
    @events = []
    @search_count = 0

    conference_events = @conference.events
    if params[:term]
        conference_events = @conference.events.with_query(params[:term])
    end

    case @report_type
    when 'lectures_with_speaker'
      r = conference_events.with_speaker.where(:event_type => :lecture)
    when 'events_without_speaker'
      r = conference_events.without_speaker
    when 'events_with__speakers'
      r = conference_events.joins(:event_people).where(:event_people => { :role_state => [:canceled, :declined, :idea, :offer, :unclear], :event_role => :speaker } )
    end

    unless r.nil?
      @search = r.search(params[:q])
      @search_count = r.count
      @events = @search.result.paginate :page => params[:page]
    end
    render :show
  end

  def show_people
    @report_type = params[:id]
    @people = []
    @search_count = 0

    conference_people = Person
    if params[:term]
        conference_people = Person.with_query(params[:term])
    end

    case @report_type
    when 'people_speaking_at'
      r = conference_people.speaking_at
    end

    unless r.nil?
      @search = r.search(params[:q])
      @search_count = r.count
      @people = @search.result.paginate :page => params[:page]
    end
    render :show
  end

end
