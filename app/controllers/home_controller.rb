class HomeController < ApplicationController
  before_action :authenticate_user!
  before_action :not_submitter!

  def index
    return redirect_to new_conference_path if Conference.count.zero?
    return redirect_to cannot_read_redirect_path if cannot? :read, Conference
    return redirect_to deleted_conference_redirect_path if @conference.nil?

    @versions = PaperTrail::Version.where(conference_id: @conference.id).includes(:item).order('created_at DESC').limit(5)
    respond_to do |format|
      format.html
    end
  end

  private

  def users_last_conference_path
    conference_home_path(conference_acronym: current_user.last_conference.acronym)
  end

  # maybe conference got deleted
  def deleted_conference_redirect_path
    return users_last_conference_path if current_user.last_conference
    new_conference_path
  end

  # maybe a crew user tries to login to the wrong conference?
  def cannot_read_redirect_path
    if current_user.is_crew?
      return users_last_conference_path if current_user.last_conference
    end
    cfp_root_path
  end
end
