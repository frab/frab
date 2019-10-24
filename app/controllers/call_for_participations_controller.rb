class CallForParticipationsController < BaseConferenceController
  def show
    authorize @conference, :read?
    @call_for_participation = @conference.call_for_participation
  end

  def new
    authorize @conference, :manage?
    @call_for_participation = CallForParticipation.new
    @call_for_participation.conference = @conference
  end

  def create
    authorize @conference, :manage?
    @call_for_participation = CallForParticipation.new(call_for_participation_params)
    @call_for_participation.conference = @conference

    if @call_for_participation.save
      redirect_to edit_call_for_participation_path, notice: t('cfp.notifications.launched')
    else
      render action: 'new'
    end
  end

  def edit
    authorize @conference, :manage?
    @call_for_participation = @conference.call_for_participation
  end

  def update
    authorize @conference, :manage?
    @call_for_participation = @conference.call_for_participation
    if @call_for_participation.update_attributes(call_for_participation_params)
      redirect_to edit_call_for_participation_path, notice: t('alert_notifications.update_successful')
    else
      flash[:alert] = t('alert_notifications.update_failed')
      flash_model_errors(@conference)
      render action: 'edit'
    end
  end

  private

  def call_for_participation_params
    params.require(:call_for_participation).permit(:start_date, :end_date, :hard_deadline, :welcome_text, :info_url, :contact_email)
  end
end
