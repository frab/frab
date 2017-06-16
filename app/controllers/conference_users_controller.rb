class ConferenceUsersController < BaseCrewController
  def index
    @admin_users = User.all_admins if current_user.is_admin?
    @conference_users = policy_scope(ConferenceUser.all).order(:user_id, :role, :conference_id)
  end

  def destroy
    conference_user = authorize ConferenceUser.find(params[:id])

    conference_user.destroy

    respond_to do |format|
      format.html { redirect_to(conference_users_path) }
    end
  end
end
