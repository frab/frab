class ConferencesController < BaseConferenceController
  include Searchable
  # these methods don't need a conference
  skip_before_action :load_conference, only: %i[new index create import create_import import_progress]
  layout :layout_if_conference

  # GET /conferences
  def index
    authorize Conference
    result = search

    respond_to do |format|
      format.html { @conferences = result.paginate(page: page_param) }
      format.json { render template: 'conferences/index', locals: { conferences: result } }
    end
  end

  # GET /conferences/1
  def show
    return redirect_to new_conference_path if Conference.count.zero?
    return redirect_to deleted_conference_redirect_path if @conference.nil?
    authorize @conference

    @versions = PaperTrail::Version.where(conference_id: @conference.id).includes(:item).order('created_at DESC').limit(5)

    respond_to do |format|
      format.html
      format.json
    end
  end

  # GET /conferences/new
  def new
    params.delete(:conference_acronym)
    @conference = authorize Conference.new
    @possible_parents = Conference.where(parent: nil)
    @first = true if Conference.count == 0

    respond_to do |format|
      format.html
    end
  end

  # GET /conferences/1/edit
  def edit
    authorize @conference, :orga?
  end

  def edit_days
    authorize @conference, :orga?
    respond_to do |format|
      format.html
    end
  end

  def edit_notifications
    authorize @conference, :orga?
    @accepting = @conference.events.where(state: 'accepting')
    @rejecting = @conference.events.where(state: 'rejecting')
    @confirmed = @conference.events.where(state: 'confirmed').scheduled
    respond_to do |format|
      format.html
    end
  end

  def edit_rooms
    authorize @conference, :orga?
    respond_to do |format|
      format.html
    end
  end

  def edit_schedule
    authorize @conference, :orga?
    respond_to do |format|
      format.html
    end
  end

  def edit_tracks
    authorize @conference, :orga?
    respond_to do |format|
      format.html
    end
  end

  def edit_ticket_server
    authorize @conference, :orga?
    respond_to do |format|
      format.html
    end
  end

  def edit_classifiers
    authorize @conference, :orga?
    respond_to do |format|
      format.html
    end
  end

  def edit_review_metrics
    authorize @conference, :orga?
    respond_to do |format|
      format.html
    end
  end

  def import
    authorize Conference, :new?
    respond_to do |format|
      format.html
    end
  end

  def create_import
    authorize Conference, :new?

    unless params[:import_file].present?
      redirect_to import_conferences_path, alert: 'Please select a file to import'
      return
    end

    begin
      # Store uploaded file temporarily
      temp_dir = Rails.root.join('tmp', 'conference_import', SecureRandom.uuid)
      FileUtils.mkdir_p(temp_dir)

      uploaded_file = params[:import_file]
      tarball_path = temp_dir.join(uploaded_file.original_filename)

      File.open(tarball_path, 'wb') do |file|
        file.write(uploaded_file.read)
      end

      # Extract tarball
      extract_dir = temp_dir.join('extracted')
      FileUtils.mkdir_p(extract_dir)

      system('tar', '-xzf', tarball_path.to_s, '-C', extract_dir.to_s)

      # Start import job
      ConferenceImportJob.perform_async(extract_dir.to_s, current_user.id)

      redirect_to import_conferences_path, notice: 'Conference import has been queued. Check the progress below.'
    rescue => e
      Rails.logger.error "Conference import error: #{e.message}"
      FileUtils.rm_rf(temp_dir) if temp_dir
      redirect_to import_conferences_path, alert: "Import failed: #{e.message}"
    end
  end

  def import_progress
    authorize Conference, :new?

    # Get latest import job status from cache/database
    job_status = Rails.cache.read("conference_import_#{current_user.id}")

    render json: {
      status: job_status&.dig(:status) || 'pending',
      progress: job_status&.dig(:progress) || 0,
      message: job_status&.dig(:message) || 'Preparing import...'
    }
  end

  def send_notification
    authorize @conference, :orga?
    SendBulkTicketJob.new.async.perform @conference, params[:notification]
    redirect_to edit_notifications_conference_path, notice: t('conferences_module.notice_bulk_notification_queued', notification: params[:notification])
  end

  # POST /conferences
  def create
    @conference = Conference.new(conference_params)
    authorize @conference, :new?

    if @conference.sub_conference? && ! policy(@conference.parent).manage?
      @conference.parent = nil
    end

    respond_to do |format|
      if @conference.save
        format.html { redirect_to(conference_path(conference_acronym: @conference.acronym), notice: t('conferences_module.notice_conference_created')) }
      else
        @possible_parents = Conference.where(parent: nil)
        flash_model_errors(@conference)
        format.html { render action: 'new' }
      end
    end
  end

  # PUT /conferences/1
  def update
    authorize @conference, :orga?
    respond_to do |format|
      if not params[:conference]
        format.html { redirect_to(edit_conference_path(conference_acronym: @conference.acronym), notice: t('conferences_module.notice_conference_not_updated')) }
      elsif @conference.update(existing_conference_params)
        format.html { redirect_to(edit_conference_path(conference_acronym: @conference.acronym), notice: t('conferences_module.notice_conference_updated')) }
      else
        flash_model_errors(@conference)
        format.html { render action: get_previous_nested_form(existing_conference_params) }
      end
    end
  end

  def default_notifications
    authorize @conference, :orga?
    locale = params[:code] || @conference.language_default
    @notification = Notification.new(locale: locale)
    @notification.default_text = locale
  end

  # DELETE /conferences/1
  def destroy
    authorize @conference, :orga?
    @conference.destroy

    respond_to do |format|
      format.html { redirect_to(conferences_path) }
    end
  end

  private

  # find the nested form which was used for the update, by looking at nested
  # attributes
  def get_previous_nested_form(parameters)
    parameters.keys.each { |name|
      attribs = name.index('_attributes')
      next if attribs.nil?
      next unless attribs.positive?

      test = name.gsub('_attributes', '')
      next unless %w(rooms days schedule notifications tracks review_metrics classifiers ticket_server).include?(test)
      return "edit_#{test}"
    }
    'edit'
  end

  def search
    @search = perform_search(Conference, params, %i(title_cont acronym_cont))
    result = @search.result(distinct: true)
    result = result.accessible_by_crew(current_user) if current_user.is_crew?
    result
  end

  def allowed_params
    [
      :acronym, :allowed_event_types_extras, :attachment_title_is_freeform, :auto_lock_on_confirm, :bcc_address,
      :bulk_notification_enabled, :color, :default_recording_license, :default_timeslots, :email,
      :event_state_visible, :expenses_enabled, :feedback_enabled, :logo, :max_timeslots, :program_export_base_url,
      :schedule_custom_css, :schedule_html_intro, :schedule_public, :schedule_open, :schedule_version, :ticket_type,
      :title, :transport_needs_enabled,
      :allowed_event_types_presets => [],
      languages_attributes: %i(language_id code _destroy id),
      ticket_server_attributes: %i(url user password queue _destroy id),
      notifications_attributes: %i(id locale accept_subject accept_body reject_subject reject_body schedule_subject schedule_body _destroy)
    ]
  end

  def conference_params
    allowed = allowed_params

    allowed += if params[:conference][:parent_id].present?
                 [:parent_id]
               else
                 [
                   :timezone, :timeslot_duration, :allowed_durations_minutes_csv,
                   days_attributes: %i(start_date end_date _destroy id)
                 ]
               end

    params.require(:conference).permit(allowed)
  end

  def existing_conference_params
    allowed = allowed_params

    allowed += [:parent_id] if @conference.new_record?

    if @conference.main_conference?
      allowed += [
        :timezone, :timeslot_duration, :allowed_durations_minutes_csv,
        days_attributes: %i(start_date end_date _destroy id)
      ]
    end

    translated_params = @conference.language_codes.map { |l|
      n = Mobility.normalize_locale(l)
      :"name_#{n}"
    }.flatten

    if @conference.main_conference? || policy(@conference.parent).manage?
      allowed += [
        classifiers_attributes: %i(name description _destroy id),
        review_metrics_attributes: %i(name description _destroy id),
        rooms_attributes: %i(name size public rank _destroy id),
        tracks_attributes: [:color, :_destroy, :id, *translated_params]
      ]
    end

    params.require(:conference).permit(allowed)
  end
end
