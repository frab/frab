class Public::ScheduleController < ApplicationController
  layout 'public_schedule'
  before_action :maybe_authenticate_user!
  before_action :set_mobility, except: %i[style qrcode]
  after_action :cors_set_access_control_headers
  
  helper Public::FeedbackHelper

  def index
    @days = @conference.days

    respond_to do |format|
      format.html
      format.xml
      format.xcal
      format.ics
      format.json
    end
  end

  def style
    respond_to do |format|
      format.css
    end
  end

  def day
    unless @day = find_day(params[:day].to_i)
      return redirect_to public_schedule_index_path, alert: t('schedule_module.error_day_not_found')
    end

    if @day.rooms_with_events.empty?
      return redirect_to public_schedule_index_path, notice: t('schedule_module.error_event_not_public')
    end

    @view_model = ScheduleViewModel.new(@conference).for_day(@day)

    respond_to do |format|
      format.html
      format.pdf do
        @layout = CustomPdf::FullPageLayout.new('A4')
        @rooms_per_page = 5
        render template: 'schedule/custom_pdf'
      end
    end
  end

  def events
    @view_model = ScheduleViewModel.new(@conference)

    respond_to do |format|
      format.html
      format.json
      format.xls { render file: Rails.root.join('app/views/public/schedule/events.xls.erb'), content_type: 'application/xls' }
    end
  end

  def timeline
    @view_model = ScheduleViewModel.new(@conference)

    respond_to do |format|
      format.html
    end
  end

  def booklet
    @view_model = ScheduleViewModel.new(@conference)

    respond_to do |format|
      format.html
    end
  end

  def event
    @view_model = ScheduleViewModel.new(@conference).for_event(params[:id])

    respond_to do |format|
      format.html
      format.ics
    end
  end

  def speakers
    @view_model = ScheduleViewModel.new(@conference)

    Mobility.with_locale(@lang) do
      respond_to do |format|
        format.html
        format.json
        format.xls { render file: Rails.root.join('app/views/public/schedule/speakers.xls.erb'), content_type: 'application/xls' }
      end
    end
  end

  def speaker
    @view_model = ScheduleViewModel.new(@conference).for_speaker(params[:id])

    respond_to do |format|
      format.html
    end
  end

  def qrcode
    @qr = RQRCode::QRCode.new(public_schedule_index_url(format: :xml), size: 8, level: :h)
  end

  private

  def find_day(day_index)
    return @conference.days.first if day_index < 1
    return @conference.days.last if day_index > @conference.days.count

    @conference.days[day_index - 1]
  end

  def maybe_authenticate_user!
    return if @conference.schedule_public

    authenticate_user!
    manage_only!
  end

  def cors_set_access_control_headers
    headers['Access-Control-Allow-Origin'] = '*'
  end

  def set_mobility
    # setting Mobility.locale is thread-safe and affects only queries, not I18n.locale translations
    Mobility.locale = if params[:lang] && @conference.language_codes.include?(params[:lang])
                        params[:lang]
                      else
                        params[:locale]
                      end
  end
end
