class CallForParticipationsController < ApplicationController

  before_filter :authenticate_user!
  before_filter :not_submitter!
  load_and_authorize_resource

  def show
    @call_for_participation = @conference.call_for_participation
  end

  def new
    @call_for_participation = CallForParticipation.new
  end

  def create
    @call_for_participation = CallForParticipation.new(params[:call_for_participations])
    @call_for_participation.conference = @conference

    if @call_for_participation.notification.nil?
      notification = Notification.new
      notification.setting_default_text(@conference.languages)

      @call_for_participation.notification = notification
    end
    
    if @call_for_participation.save
      redirect_to call_for_participation_path, notice: "Launched Call for Papers."
    else
      render action: "new"
    end
  end

  def edit
    @call_for_participation = @conference.call_for_participation
  end

  def edit_notification
    @call_for_participation = @conference.call_for_participation

    if @call_for_participation.notification.nil?
      notification = Notification.new
      notification.setting_default_text( @call_for_participation.conference.languages )

      @call_for_participation.notification = notification
    end
      @notification = @conference.call_for_participation.notification
  end

  def update
    @call_for_participation = @conference.call_for_participation
    @notification    = @conference.call_for_participation.notification

    if @call_for_participation.update_attributes(params[:call_for_participations])
      @notification.update_attributes(params[:notification]) unless @notification.nil?
      redirect_to call_for_participation_path, notice: "Changes saved successfully!"
    else
      render action: "edit"
    end
  end
end
