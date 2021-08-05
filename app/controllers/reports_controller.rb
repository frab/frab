class ReportsController < BaseConferenceController
  before_action :orga_only!

  def index
    respond_to do |format|
      format.html
    end
  end

  def show_events
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
    when 'events_without_subtitle'
      r = conference_events.where.not(state: [:rejected, :withdrawn, :canceled]).where(subtitle: '')
    when 'unconfirmed_lectures'
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
      format.json
    end
  end

  def show_people
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
        .where('event_people.event_role': EventPerson::SPEAKERS)
        .where('event_people.role_state': 'confirmed')
        .where('events.public': true)
        .where('events.start_time > ?', Time.now)
        .where('events.start_time < ?', Time.now.since(4.hours))
        .where('events.state': %w(unconfirmed confirmed scheduled))
        .distinct
    when 'people_speaking_at'
      r = conference_people.speaking_at(@conference)
    when 'people_with_a_note'
      r = conference_people.involved_in(@conference).where(Person.arel_table[:note].not_eq(''))
    when 'people_with_more_than_one'
      r = conference_people.involved_in(@conference).where('event_people.event_role' => ['submitter']).group('people.id').having('count(*) > 1')
    when 'people_with_non_reimbursed_expenses'
      r = conference_people.involved_in(@conference).joins(:expenses).where('expenses.value > 0 AND expenses.reimbursed = ? AND expenses.conference_id = ?', false, @conference.id)
      @total_sum = 0
      r.each do |p|
        @total_sum += p.sum_of_expenses(@conference, false)
      end

      @extra_fields << :expenses
    when 'non_attending_speakers'
      r = Person.joins(events: :conference)
        .where('conferences.id': @conference.id)
        .where('event_people.event_role': 'speaker')
        .where("event_people.role_state != 'attending'")
        .where('events.public': true)
        .where('events.start_time > ?', Time.now)
        .where('events.start_time < ?', Time.now.since(2.hours))
        .where('events.state': %w(accepting unconfirmed confirmed scheduled))
        .distinct
    when 'speakers_without_availabilities'
      r = Person.joins(events: :conference)
        .includes(:availabilities)
        .where('conferences.id': @conference.id)
        .where('event_people.event_role': EventPerson::SPEAKERS)
        .where('event_people.role_state': [ 'confirmed', 'scheduled' ])
        .where(availabilities: { person_id: nil })
    end

    unless r.nil? or r.empty?
      @search = r.search(params[:q])
      @search_count = r.length
      @people = @search.result.paginate page: page_param
    end
    respond_to do |format|
      format.html { render :show }
      format.json
    end
  end
  
  def show_statistics
    @report_type = params[:id]
    @search_count = 0

    case @report_type
    when 'confirmed_events_by_track'
      statistics_for_events_by_track(@conference.events.confirmed)
    when 'events_by_track'
      statistics_for_events_by_track(@conference.events.candidates)
    when 'event_timeslot_sum'
      @data = []
      row = []
      @labels = [t('lectures_commited'), t('lectures_confirmed'), t('lectures_unconfirmed'), t('lectures'), t('workshops')]
      events = @conference.events.where(event_type: :lecture, state: [:accepting, :confirmed, :unconfirmed, :scheduled])
      row << @conference.event_duration_sum(events)
      events = @conference.events.where(event_type: :lecture, state: [:confirmed, :scheduled])
      row << @conference.event_duration_sum(events)
      events = @conference.events.where(event_type: :lecture, state: [:acepting, :unconfirmed])
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
      @labels = [t('day'), t('full_name'), t('public_name'), t('email'), t('event'), t('role_str'), t('state')]

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
      format.json { render json: @data.to_json }
    end
  end

  def show_transport_needs
    @search = @conference.transport_needs.search(params[:q])
    @transport_needs = @search.result
    @report_type = params[:id]

    respond_to do |format|
      format.html { render :show }
      format.json { render json: @transport_needs.to_json }
    end
  end
  
  protected
  
  def statistics_for_events_by_track(events)
    @data = []
    row = []
    @labels = @conference.tracks.collect(&:name)
    @labels.each { |track|
      row << events.joins(:track).where(tracks: { name: track }).count
    }
    number_of_trackless = events.count - row.inject(0, :+)
    if number_of_trackless > 0
      @labels << t('not_specified')
      row << number_of_trackless
    end  
    @data << row
    @search_count = row.inject(0, :+)
  end

end
