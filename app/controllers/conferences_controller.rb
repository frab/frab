class ConferencesController < ApplicationController
  # these methods don't need a conference
  skip_before_action :load_conference, only: [:new, :index, :create]

  before_action :authenticate_user!
  before_action :not_submitter!
  load_and_authorize_resource

  # GET /conferences
  def index
    result = search params
    @conferences = result.paginate page: page_param

    respond_to do |format|
      format.html
      format.json { render json: @conferences }
    end
  end

  # GET /conferences/1
  def show
    @conference = Conference.find(params[:id])

    respond_to do |format|
      format.html
      format.json { render json: @conference }
    end
  end

  # GET /conferences/new
  def new
    params.delete(:conference_acronym)
    @conference = Conference.new
    @first = true if Conference.count == 0

    respond_to do |format|
      format.html
    end
  end

  # GET /conferences/1/edit
  def edit
  end

  def edit_notifications
    respond_to do |format|
      format.html
    end
  end

  # POST /conferences
  def create
    @conference = Conference.new(conference_params)

    respond_to do |format|
      if @conference.save
        format.html { redirect_to(conference_home_path(conference_acronym: @conference.acronym), notice: 'Conference was successfully created.') }
      else
        format.html { render action: 'new' }
      end
    end
  end

  # PUT /conferences/1
  def update
    respond_to do |format|
      if @conference.update_attributes(conference_params)
        format.html { redirect_to(edit_conference_path(conference_acronym: @conference.acronym), notice: 'Conference was successfully updated.') }
      else
        # redirect to the right nested form page
        flash[:errors] = @conference.errors.full_messages.join
        format.html { render action: get_previous_nested_form(conference_params) }
      end
    end
  end

  def default_notifications
    locale = params[:code]
    @notification = Notification.new(locale: locale)
    @notification.default_text = locale
  end

  # DELETE /conferences/1
  def destroy
    @conference.destroy

    respond_to do |format|
      format.html { redirect_to(conferences_path) }
    end
  end

  private

  def get_previous_nested_form(parameters)
    parameters.keys.each { |name|
      attribs = name.index('_attributes')
      next if attribs.nil?
      next unless attribs > 0
      test = name.gsub('_attributes', '')
      next unless %w(rooms days schedule tracks ticket_server ).include?(test)
      return "edit_#{test}"
    }
    'edit'
  end

  def search(params)
    if params.key?(:term) and not params[:term].empty?
      term = params[:term]
      sort = begin
               params[:q][:s]
             rescue
               nil
             end
      @search = Conference.ransack(title_cont: term,
                                   acronym_cont: term,
                                   m: 'or',
                                   s: sort)
    else
      @search = Conference.ransack(params[:q])
    end

    @search.result(distinct: true)
  end

  def conference_params
    params.require(:conference).permit(
      :acronym, :title, :timezone, :timeslot_duration, :default_timeslots, :max_timeslots, :feedback_enabled, :email, :program_export_base_url, :schedule_version, :schedule_public, :color, :ticket_type, :event_state_visible, :schedule_custom_css, :schedule_html_intro, :default_recording_license,
      rooms_attributes: %i(name size public rank _destroy id),
      days_attributes: %i(start_date end_date _destroy id),
      tracks_attributes: %i(name color _destroy id),
      languages_attributes: %i(language_id code _destroy id),
      ticket_server_attributes: %i(url user password queue _destroy id),
      notifications_attributes: %i(id locale accept_subject accept_body reject_subject reject_body _destroy)
    )
  end
end
