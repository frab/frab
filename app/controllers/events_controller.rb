class EventsController < BaseConferenceController
  include Searchable

  # GET /events
  # GET /events.json
  def index
    authorize @conference, :read?
    @events = search @conference.events.includes(:track)

    clean_events_attributes
    respond_to do |format|
      format.html {
                    @num_of_matching_events = @events.count
                    if helpers.showing_my_events?
                      @events_total = @conference.events.associated_with(current_user.person).count
                    else
                      @events_total = @conference.events.count
                    end
                    @events = @events.paginate page: page_param
                  }
      format.json
    end
  end

  def export_accepted
    authorize @conference, :read?
    @events = @conference.events.is_public.accepted

    respond_to do |format|
      format.json { render :export }
    end
  end

  def export_confirmed
    authorize @conference, :read?
    @events = @conference.events.is_public.confirmed

    respond_to do |format|
      format.json { render :export }
    end
  end

  def export_all
    authorize @conference, :manage?
    @events = @conference.events.all

    respond_to do |format|
      format.json { render :export }
    end
  end

  # current_users events
  def my
    authorize @conference, :read?

    redirect_to events_path(events: 'my')
  end

  def filter_modal
    authorize @conference, :read?

    @filter = helpers.filters_data.detect{|f| f.qname == params[:which_filter]}

    case @filter.type
    when :text
      @options = helpers.localized_filter_options(@conference.events.includes(:track).distinct.pluck(@filter.attribute_name), @filter.i18n_scope)
      @selected_values = helpers.split_filter_string(params[@filter.qname]) if params[@filter.qname]
    when :range
      @op, @current_numeric_value = helpers.get_op_and_val(params[@filter.qname])
    end

    render partial: 'filter_modal'
  end

  def bulk_edit_modal
    authorize @conference, :read?
    @events = search @conference.events_with_review_averages.includes(:track)
    @num_of_matching_events = @events.reorder('').pluck(:id).count

    render partial: 'bulk_edit_modal'
  end

  # events as pdf
  def cards
    authorize @conference, :manage?
    @events = if params[:accepted]
                @conference.events.accepted
              else
                @conference.events
              end

    respond_to do |format|
      format.pdf
    end
  end

  # show a table of all events' attachments
  def attachments
    authorize @conference, :read?

    result = search @conference.events.includes(:track)

    @num_of_matching_events = result.count
    @events_total = @conference.events.count

    @events = result.paginate page: page_param
    clean_events_attributes

    attachments = EventAttachment.joins(:event).where('events.conference': @conference)
    preset_attachment_titles_in_use = attachments.where(title: EventAttachment::ATTACHMENT_TITLES).group(:title).pluck(:title)

    @attachment_titles = EventAttachment::ATTACHMENT_TITLES & preset_attachment_titles_in_use

    @other_attachment_titles_exist = attachments.where.not(title: EventAttachment::ATTACHMENT_TITLES).any?
  end

  # show event ratings
  def ratings
    authorize @conference, :read?

    result = search @conference.events_with_review_averages.includes(:track)
    @events = result.paginate page: page_param
    clean_events_attributes

    @num_of_matching_events = result.reorder('').pluck(:id).count

    # total ratings:
    @events_total = @conference.events.count
    @events_reviewed_total = @conference.events.to_a.count { |e| !e.event_ratings_count.nil? && e.event_ratings_count > 0 }
    @events_no_review_total = @events_total - @events_reviewed_total

    # current_user rated:
    @events_reviewed = @conference.events.joins(:event_ratings).where('event_ratings.person_id' => current_user.person.id).where.not('event_ratings.rating' => [nil, 0]).count
    @events_no_review = @events_total - @events_reviewed
  end

  # show event feedbacks
  def feedbacks
    authorize @conference, :read?
    result = search @conference.events.accepted
    @events = result.paginate page: page_param
  end

  # show event history
  def history
    authorize @conference, :orga?
    @event = Event.find(params[:event_id])
    @all_versions = PaperTrail::Version.where(item_type: 'Event', item: @event.id).or(PaperTrail::Version.where(associated_type: 'Event', associated_id: @event.id)).order('created_at DESC')
    @versions = @all_versions.paginate(
      page: page_param,
      per_page: 25
    )
    respond_to do |format|
      format.html
      format.xml { render xml: @all_versions }
      format.json { render json: @all_versions.to_json }
    end
  end

  def translations
    @event = authorize Event.find(params[:id])

    @translations = @event.translations
  end

  # start batch event review
  def start_review
    authorize @conference, :read?
    ids = Event.ids_by_least_reviewed(@conference, current_user.person)
    if ids.empty?
      redirect_to action: 'ratings', notice: t('ratings_module.notice_already_rated_everything')
    else
      session[:review_ids] = ids
      redirect_to event_event_rating_path(event_id: ids.first)
    end
  end

  # batch actions
  def batch_actions
    if params[:bulk_email]
      bulk_send_email
    elsif params[:bulk_set]
      bulk_set
    elsif params[:bulk_add_person]
      bulk_add_person
    else
      redirect_to events_path, alert: :illegal
    end
  end

  def bulk_send_email
    authorize @conference, :orga?

    mail_template = @conference.mail_templates.find_by(name: params[:template_name])
    redirect_back(alert: t('ability.denied'), fallback_location: root_path) and return if mail_template.blank?

    events = search @conference.events_with_review_averages.includes(:track)
    event_people = EventPerson.where(event_id: events.to_a.pluck(:id))

    if Rails.env.production?
      SendBulkMailJob.new.async.perform(mail_template, event_people)
      redirect_back(notice: t('emails_module.notice_mails_queued'), fallback_location: root_path)
    else
      SendBulkMailJob.new.perform(mail_template, event_people)
      redirect_back(notice: t('emails_module.notice_mails_delivered'), fallback_location: root_path)
    end
  end

  def bulk_set
    authorize @conference, :orga?
    events = search @conference.events_with_review_averages.includes(:track)

    total_successful = 0
    total_skipped = 0
    total_failed = 0
    events.each do |event|
      if event.try(params[:bulk_set_attribute]) == params[:bulk_set_value]
        total_skipped +=1
      elsif event.update( params[:bulk_set_attribute] => params[:bulk_set_value] )
        total_successful += 1
      else
        total_failed += 1
      end
    end

    summary = [  t('events_module.bulk_edit.update_successful', count: total_successful),
                (t('events_module.bulk_edit.update_skipped', count: total_skipped) if total_skipped > 0),
                (t('events_module.bulk_edit.update_failed', count: total_failed)   if total_failed > 0)  ].join(' ')

    if total_failed > 0
      redirect_back alert: summary, fallback_location: root_path
    else
      redirect_back notice: summary, fallback_location: root_path
    end
  end

  def bulk_add_person
    authorize @conference, :orga?
    events = search @conference.events_with_review_averages.includes(:track)

    person_id = params[:person_id]
    event_role = params[:event_role]
    redirect_back(alert: t('ability.denied'), fallback_location: root_path) and return if person_id.blank? or event_role.blank?

    total_successful = 0
    total_skipped = 0
    total_failed = 0

    events.each do |event|
      if EventPerson.where(event: event, person_id:  person_id, event_role: event_role).any?
        total_skipped +=1
      elsif event.update( event_people_attributes: { 'x' => { person_id:  person_id,
                                                              event_role: event_role } } )
        total_successful += 1
      else
        total_failed += 1
      end
    end

    summary = [  t('events_module.bulk_edit.update_successful', count: total_successful),
                (t('events_module.bulk_edit.update_skipped', count: total_skipped) if total_skipped > 0),
                (t('events_module.bulk_edit.update_failed', count: total_failed)   if total_failed > 0)  ].join(' ')

    if total_failed > 0
      redirect_back alert: summary, fallback_location: root_path
    else
      redirect_back notice: summary, fallback_location: root_path
    end
  end

  # GET /events/1
  # GET /events/1.json
  def show
    @event = authorize Event.find(params[:id])

    clean_events_attributes
    respond_to do |format|
      format.html # show.html.erb
      format.json
    end
  end

  # people tab of event detail page, the rating and
  # feedback tabs are handled in routes.rb
  # GET /events/2/people
  def people
    @event = authorize Event.find(params[:id])
  end

  # GET /events/new
  def new
    authorize @conference, :manage?
    @event = Event.new
    @start_time_options = @conference.start_times_by_day

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # GET /events/1/edit
  def edit
    @event = authorize Event.find(params[:id])
    @start_time_options = PossibleStartTimes.new(@event).all
  end

  # GET /events/2/edit_people
  def edit_people
    @event = authorize Event.find(params[:id])
    @persons = Person.fullname_options
  end

  # POST /events
  def create
    @event = Event.new(event_params)
    @event.conference = @conference
    authorize @event

    respond_to do |format|
      if @event.save
        format.html { redirect_to(@event, notice: t('cfp.event_created_notice')) }
      else
        @start_time_options = @conference.start_times_by_day
        format.html { render action: 'new' }
      end
    end
  end

  # PUT /events/1
  def update
    @event = authorize Event.find(params[:id])

    respond_to do |format|
      if @event.update(event_params)
        format.html { redirect_to(@event, notice: t('cfp.event_updated_notice')) }
        format.js   { head :ok }
      else
        flash_model_errors(@event)
        @start_time_options = PossibleStartTimes.new(@event).all
        format.html { render action: 'edit' }
        format.js { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # update event state
  # GET /events/2/update_state?transition=cancel
  def update_state
    @event = authorize Event.find(params[:id])

    if params[:send_mail]

      # If integrated mailing is used, take care that a notification text is present.
      if @event.conference.notifications.empty?
        return redirect_to edit_conference_path, alert: t('emails_module.error_missing_notification_text')
      end

      return redirect_to(@event, alert: t('emails_module.error_missing_conference_email')) unless @conference.email

      return redirect_to(@event, alert: t('emails_module.error_missing_speaker_email')) unless @event.speakers.all?(&:email)
    end

    return redirect_to(@event, alert: t('emails_module.error_state_update')) unless @event.transition_possible?(params[:transition])

    begin
      @event.send(:"#{params[:transition]}!", send_mail: params[:send_mail], coordinator: current_user.person)
    rescue => ex
      return redirect_to(@event, alert: t('emails_module.error_state_update_ex', ex: ex))
    end

    redirect_to @event, notice: t('emails_module.notice_event_updated')
  end

  # add custom notifications to all the event's subscribers
  # POST /events/2/custom_notification
  def custom_notification
    @event = authorize Event.find(params[:id])

    case @event.state
    when 'accepting'
      state = 'accept'
    when 'rejecting'
      state = 'reject'
    when 'confirmed'
      state = 'schedule'
    else
      return redirect_to(@event, alert: t('emails_module.error_unnotifiable_state'))
    end

    begin
      @event.event_people.subscriber.each { |p| p.set_default_notification(state) }
    rescue Errors::NotificationMissingException => ex
      return redirect_to(@event, alert: t('emails_module.error_failed_setting_notification', ex: ex))
    end

    redirect_to edit_people_event_path(@event)
  end

  # DELETE /events/1
  def destroy
    @event = authorize Event.find(params[:id])
    @event.destroy

    respond_to do |format|
      format.html { redirect_to(events_url) }
    end
  end

  private

  def clean_events_attributes
    return if policy(@conference).manage?
    @event&.clean_event_attributes!
    @events&.map(&:clean_event_attributes!)
  end

  # returns duplicates if ransack has to deal with the associated model
  def search(events)
    filter = events
    helpers.filters_data.each do |f|
      if params[f.qname]
        filter = filter.where(f.attribute_name => criteria_from_param(f))
      end
    end
    filter = filter.associated_with(current_user.person) if helpers.showing_my_events?
    @search = perform_search(filter, params, %i(title_cont description_cont abstract_cont track_name_cont event_type_is id_in))
    if params.dig('q', 's')&.match('track_name')
      @search.result
    else
      @search.result(distinct: true)
    end
  end

  def criteria_from_param(f)
    s = params[f.qname]
    case f.type
    when :text
      c = helpers.split_filter_string(s)
      c += [nil] if c.include?('')
      return c
    when :range
      op,val = helpers.get_op_and_val(params[f.qname])
      val = val.to_f
      return (val..Float::INFINITY) if op == '≥'
      return (Float::INFINITY..val) if op == '≤'
      return val
    end
  end

  def event_params
    translated_params = @conference.language_codes.map { |l|
      n = Mobility.normalize_locale(l)
      [:"title_#{n}", :"subtitle_#{n}", :"abstract_#{n}", :"description_#{n}"]
    }.flatten

    params.require(:event).permit(
      :id, :title, :subtitle, :event_type, :time_slots, :state, :start_time, :public, :language, :abstract, :description, :logo, :track_id, :room_id, :note, :submission_note, :do_not_record, :recording_license, :tech_rider,
      *translated_params,
      event_attachments_attributes: %i(id title attachment public _destroy),
      ticket_attributes: %i(id remote_ticket_id),
      links_attributes: %i(id title url _destroy),
      event_classifiers_attributes: %i(id classifier_id value _destroy),
      event_people_attributes: %i(id person_id event_role role_state notification_subject notification_body _destroy)
    )
  end
end
