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
    when 'events_that_are_workshops'
      r = conference_events.where(Event.arel_table[:event_type].eq(:workshop))
    when 'event_timeslot_deviation'
      r = conference_events.where(:event_type => :lecture).where('time_slots != ?', @conference.default_timeslots)
    when 'events_that_are_no_lectures'
      r = conference_events.where(Event.arel_table[:event_type].not_eq(:lecture).and(Event.arel_table[:event_type].not_eq(:workshop)))
    when 'events_without_speaker'
      r = conference_events.without_speaker
    when 'events_with_unconfirmed_speakers'
      r = conference_events.joins(:event_people).where(:event_people => { :role_state => [:canceled, :declined, :idea, :offer, :unclear], :event_role => :speaker } )
    end

    unless r.nil? or r.empty?
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
      r = conference_people.speaking_at(@conference)
    when 'people_with_a_note'
      r = conference_people.involved_in(@conference).where(Person.arel_table[:note].not_eq(""))
    end

    unless r.nil? or r.empty?
      @search = r.search(params[:q])
      @search_count = r.count
      @people = @search.result.paginate :page => params[:page]
    end
    render :show
  end

end
