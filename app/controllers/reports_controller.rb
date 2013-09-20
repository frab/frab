class ReportsController < ApplicationController

  before_filter :authenticate_user!
  before_filter :not_submitter!

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
      r = conference_events.with_speaker.where(event_type: :lecture)
    when 'lectures_not_confirmed'
      r = conference_events.with_speaker.where(event_type: :lecture, state: [:new,:review] )
      when 'events_not_public'
      r = conference_events.where(public: false)
    when 'events_that_are_workshops'
      r = conference_events.where(Event.arel_table[:event_type].eq(:workshop))
    when 'event_timeslot_deviation'
      r = conference_events.where(event_type: :lecture).where('time_slots != ?', @conference.default_timeslots)
    when 'events_that_are_no_lectures'
      r = conference_events.where(Event.arel_table[:event_type].not_eq(:lecture).and(Event.arel_table[:event_type].not_eq(:workshop)))
    when 'events_without_speaker'
      r = conference_events.without_speaker
    when 'unconfirmed_events'
      r = conference_events.where(event_type: :lecture, state: :unconfirmed)
    when 'events_with_a_note'
      r = conference_events.where(Event.arel_table[:note].not_eq("").or(Event.arel_table[:submission_note].not_eq("")))
    when 'events_with_unusual_state_speakers'
      r = conference_events.joins(:event_people).where(event_people: { role_state: [:canceled, :declined, :idea, :offer, :unclear], event_role: [:moderator, :speaker] } )
    end

    unless r.nil? or r.empty?
      @search = r.search(params[:q])
      @search_count = r.count
      @events = @search.result.paginate page: params[:page]
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
    when 'people_with_more_than_one'
      r = conference_people.involved_in(@conference).where("event_people.event_role" => ["submitter"]).group('event_people.person_id').having('count(*) > 1')
    end

    unless r.nil? or r.empty?
      @search = r.search(params[:q])
      @search_count = r.length
      @people = @search.result.paginate page: params[:page]
    end
    render :show
  end

  def show_statistics
    authorize! :show, @conference

    @report_type = params[:id]
    @search_count = 0

    case @report_type
    when 'confirmed_events_by_track'
      @data = []
      row = []
      @labels = @conference.tracks.collect { |t| t.name }
      @labels.each { |track|
        row << @conference.events.confirmed.joins(:track).where(tracks: { name: track}).count
      }
      @data << row
      @search_count = row.inject(:+)

    when 'events_by_track'
      @data = []
      row = []
      @labels = @conference.tracks.collect { |t| t.name }
      @labels.each { |track|
        row << @conference.events.candidates.joins(:track).where(tracks: { name: track}).count
      }
      @data << row
      @search_count = row.inject(:+)

    when 'event_timeslot_sum'
      @data = []
      row = []
      @labels = %w{LecturesCommited LecturesConfirmed LecturesUnconfirmed Lectures Workshops}
      events = @conference.events.where(event_type: :lecture, state: [:confirmed, :unconfirmed])
      row << @conference.event_duration_sum(events)
      events = @conference.events.where(event_type: :lecture, state: :confirmed)
      row << @conference.event_duration_sum(events)
      events = @conference.events.where(event_type: :lecture, state: :unconfirmed)
      row << @conference.event_duration_sum(events)
      events = @conference.events.where(event_type: :lecture)
      row << @conference.event_duration_sum(events)
      events = @conference.events.where(event_type: :workshops)
      row << @conference.event_duration_sum(events)
      @data << row
    end

    render :show
  end

end
