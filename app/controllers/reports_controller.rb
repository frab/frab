class ReportsController < ApplicationController
  before_action :authenticate_user!
  before_action :not_submitter!

  def index
    respond_to do |format|
      format.html
    end
  end

  def show_events
    authorize! :manage, CallForParticipation

    @report_type = params[:id]
    @events = []
    @search_count = 0
    @extra_fields = []

    conference_events = @conference.events
    if params[:term]
      conference_events = @conference.events.ransack(params[:term]).result
    end

    case @report_type
    when 'lectures_with_speaker'
      r = conference_events.with_speaker.where(event_type: :lecture)
    when 'lectures_not_confirmed'
      r = conference_events.with_speaker.where(event_type: :lecture, state: [:new, :review])
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
    when 'events_with_more_than_one_speaker'
      r = conference_events.with_more_than_one_speaker
    when 'events_without_abstract'
      r = conference_events.where(Event.arel_table[:abstract].eq(''))
    when 'unconfirmed_events'
      r = conference_events.where(event_type: :lecture, state: :unconfirmed)
    when 'events_with_a_note'
      r = conference_events.where(Event.arel_table[:note].not_eq('').or(Event.arel_table[:submission_note].not_eq('')))
    when 'events_with_unusual_state_speakers'
      r = conference_events.joins(:event_people).where(event_people: { role_state: [:canceled, :declined, :idea, :offer, :unclear], event_role: [:moderator, :speaker] })
    when 'do_not_record_events'
      r = conference_events.where(do_not_record: true)
    when 'events_with_tech_rider'
      r = conference_events
          .scheduled
          .where(Event.arel_table[:tech_rider].not_eq(''))
      @extra_fields << :tech_rider
    end

    unless r.nil? or r.empty?
      @search = r.search(params[:q])
      @search_count = r.count
      @events = @search.result.paginate page: page_param
    end
    respond_to do |format|
      format.html { render :show }
    end
  end

  def show_people
    authorize! :manage, CallForParticipation

    @report_type = params[:id]
    @people = []
    @search_count = 0
    @extra_fields = []

    conference_people = Person
    conference_people = Person.ransack(params[:term]).result if params[:term]

    case @report_type
    when 'expected_speakers'
      r = Person.joins(events: :conference)
          .where('conferences.id': @conference.id)
          .where('event_people.event_role': %w(speaker moderator))
          .where('event_people.role_state': 'confirmed')
          .where('events.public': true)
          .where('events.start_time > ?', Time.now)
          .where('events.start_time < ?', Time.now.since(4.hours))
          .where('events.state': %w(unconfirmed confirmed)).order('events.start_time ASC').group(:'people.id')
    when 'people_speaking_at'
      r = conference_people.speaking_at(@conference)
    when 'people_with_a_note'
      r = conference_people.involved_in(@conference).where(Person.arel_table[:note].not_eq(''))
    when 'people_with_more_than_one'
      r = conference_people.involved_in(@conference).where('event_people.event_role' => ['submitter']).group('event_people.person_id').having('count(*) > 1')
    when 'people_with_non_reimbursed_expenses'
      r = conference_people.involved_in(@conference).joins(:expenses).where('expenses.value > 0 AND expenses.reimbursed = "f" AND expenses.conference_id = ?', @conference.id)
      @total_sum = 0
      r.each do |p|
        @total_sum += p.sum_of_expenses(@conference, false)
      end

      @extra_fields << :expenses
    end

    unless r.nil? or r.empty?
      @search = r.search(params[:q])
      @search_count = r.length
      @people = @search.result.paginate page: page_param
    end
    respond_to do |format|
      format.html { render :show }
    end
  end

  def show_statistics
    authorize! :manage, CallForParticipation

    @report_type = params[:id]
    @search_count = 0

    case @report_type
    when 'confirmed_events_by_track'
      @data = []
      row = []
      @labels = @conference.tracks.collect(&:name)
      @labels.each { |track|
        row << @conference.events.confirmed.joins(:track).where(tracks: { name: track }).count
      }
      @data << row
      @search_count = row.inject(:+)

    when 'events_by_track'
      @data = []
      row = []
      @labels = @conference.tracks.collect(&:name)
      @labels.each { |track|
        row << @conference.events.candidates.joins(:track).where(tracks: { name: track }).count
      }
      @data << row
      @search_count = row.inject(:+)

    when 'event_timeslot_sum'
      @data = []
      row = []
      @labels = %w(LecturesCommited LecturesConfirmed LecturesUnconfirmed Lectures Workshops)
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
      @search_count = nil

    when 'people_speaking_by_day'
      @data = []
      row = []
      @labels = %w(Day FullName PublicName Email Event Role State) # TODO translate

      @conference.days.each do |day|
        @conference.events.confirmed.no_conflicts.is_public.scheduled_on(day).order(:start_time).each do |event|
          event.event_people.presenter.each do |event_person|
            person = event_person.person
            row = [l(day.date), person.full_name, person.public_name, person.email, event.title, event_person.event_role, event_person.role_state]
            @data << row
          end
        end
      end

      @search_count = nil
    end

    respond_to do |format|
      format.html { render :show }
    end
  end

  def show_transport_needs
    authorize! :manage, CallForParticipation

    @search = @conference.transport_needs.search(params[:q])
    @transport_needs = @search.result
    @report_type = params[:id]

    render :show
  end

end
