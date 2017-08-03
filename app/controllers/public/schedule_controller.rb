class Public::ScheduleController < ApplicationController
  layout 'public_schedule'
  before_action :maybe_authenticate_user!
  after_action :cors_set_access_control_headers

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
      return redirect_to public_schedule_index_path, alert: 'Failed to find day.'
    end

    if @day.rooms_with_events.empty?
      return redirect_to public_schedule_index_path, notice: 'No events are public and scheduled.'
    end

    @view_model = ScheduleViewModel.new(@conference).for_day(@day)

    respond_to do |format|
      format.html
      format.pdf do
        @layout = CustomPDF::FullPageLayout.new('A4')
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
      format.xls { render file: 'public/schedule/events.xls.erb', content_type: 'application/xls' }
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
    respond_to do |format|
      format.html
      format.json
      format.xls { render file: 'public/schedule/speakers.xls.erb', content_type: 'application/xls' }
    end
  end

  def speaker
    @view_model = ScheduleViewModel.new(@conference).for_speaker(params[:id])
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
    authenticate_user! unless @conference.schedule_public
  end

  private

  def cors_set_access_control_headers
    headers['Access-Control-Allow-Origin'] = '*'
  end
end
