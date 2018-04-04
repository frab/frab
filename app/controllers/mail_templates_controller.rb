class MailTemplatesController < BaseConferenceController
  before_action :orga_only!

  def new
    @mail_template = MailTemplate.new
  end

  def edit
    @mail_template = @conference.mail_templates.find(params[:id])
  end

  def show
    @mail_template = @conference.mail_templates.find(params[:id])
    @send_filter_options = [
      [t('emails_module.filters.all_speakers_in_confirmed_events'),   :all_speakers_in_confirmed_events],
      [t('emails_module.filters.all_speakers_in_unconfirmed_events'), :all_speakers_in_unconfirmed_events],
      [t('emails_module.filters.all_speakers_in_scheduled_event'),    :all_speakers_in_scheduled_events]
    ]
  end

  def send_mail
    @mail_template = @conference.mail_templates.find(params[:id])
    send_filter = params[:send_filter]

    if Rails.env.production?
      @mail_template.send_async(send_filter)
      redirect_to(@mail_template, notice: t('emails_module.notice_mails_queued'))
    else
      @mail_template.send_sync(send_filter)
      redirect_to(@mail_template, notice: t('emails_module.notice_mails_delivered'))
    end
  end

  def index
    result = search @conference.mail_templates, params
    @mail_templates = result.paginate page: page_param
  end

  def update
    @mail_template = @conference.mail_templates.find(params[:id])

    respond_to do |format|
      if @mail_template.update_attributes(mail_template_params)
        format.html { redirect_to(@mail_template, notice: t('emails_module.notice_template_updated')) }
        format.xml  { head :ok }
        format.js   { head :ok }
      else
        flash_model_errors(@mail_template)
        format.html { render action: 'edit' }
        format.xml  { render xml: @mail_template.errors, status: :unprocessable_entity }
      end
    end
  end

  def create
    t = MailTemplate.new(mail_template_params)
    @conference.mail_templates << t
    redirect_to(mail_templates_path, notice: t('emails_module.notice_transport_need_added'))
  end

  def destroy
    @conference.mail_templates.find(params[:id]).destroy
    redirect_to(mail_templates_path, notice: t('emails_module.notice_template_destroyed'))
  end

  private

  def search(mail_templates, params)
    if params.key?(:term) and not params[:term].empty?
      term = params[:term]
      sort = begin
               params[:q][:s]
             rescue
               nil
             end
      @search = mail_templates.ransack(name_cont: term,
                                       subject_cont: term,
                                       content_cont: term,
                                       m: 'or',
                                       s: sort)
    else
      @search = mail_templates.ransack(params[:q])
    end

    @search.result(distinct: true)
  end

  def mail_template_params
    params.require(:mail_template).permit(:name, :subject, :content)
  end
end
