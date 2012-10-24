class ReportsController < ApplicationController

  before_filter :authenticate_user!

  def index
  end

  def show_events
    authorize! :show, @conference

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
    when 'lectures_not_confirmed'
      r = conference_events.with_speaker.where(:event_type => :lecture, :state => [:new,:review] )
    when 'events_that_are_workshops'
      r = conference_events.where(Event.arel_table[:event_type].eq(:workshop))
    when 'event_timeslot_deviation'
      r = conference_events.where(:event_type => :lecture).where('time_slots != ?', @conference.default_timeslots)
    when 'events_that_are_no_lectures'
      r = conference_events.where(Event.arel_table[:event_type].not_eq(:lecture).and(Event.arel_table[:event_type].not_eq(:workshop)))
    when 'events_without_speaker'
      r = conference_events.without_speaker
    when 'unconfirmed_events'
      r = conference_events.where(:event_type => :lecture, :state => :unconfirmed)
    when 'events_with_unusual_state_speakers'
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
    authorize! :show, @conference

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
      @search_count = r.length
      @people = @search.result.paginate :page => params[:page]
    end
    render :show
  end

  def show_statistics
    authorize! :show, @conference

    @report_type = params[:id]
    @search_count = 0

    case @report_type
    when 'events_by_track'
      @data = []
      row = []
      @labels = Track.all.collect { |t| t.name }
      @labels.each { |track|
        row << @conference.events.confirmed.joins(:track).where(:tracks => { :name => track}).count
      }
      @data << row
      @search_count = row.inject(:+)

    when 'event_timeslot_sum'
      @data = []
      row = []
      @labels = %w{LecturesCommited LecturesConfirmed LecturesUnconfirmed Lectures Workshops}
      events = @conference.events.where(:event_type => :lecture, :state => [:confirmed, :unconfirmed])
      row << event_duration_sum(events)
      events = @conference.events.where(:event_type => :lecture, :state => :confirmed)
      row << event_duration_sum(events)
      events = @conference.events.where(:event_type => :lecture, :state => :unconfirmed)
      row << event_duration_sum(events)
      events = @conference.events.where(:event_type => :lecture)
      row << event_duration_sum(events)
      events = @conference.events.where(:event_type => :workshops)
      row << event_duration_sum(events)
      @data << row
    end

    render :show
  end

  protected

  def event_duration_sum(events)
    # FIXME adjust for configurable duration and move to model
    hours = events.map { |e| 
      if e.time_slots < 5
        1
      else
        v = e.time_slots / 4
        v += 1 if e.time_slots % 4
        v
      end
    }
    hours.sum
  end


end
