class ConferenceUsersController < BaseCrewController
  def index
    @users = policy_scope(ConferenceUser.all).order(:user_id, :role, :conference_id).paginate(page: page_param)
  end

  def admins
    authorize User, :index?
    @users = User.all_admins.order(:email).paginate(page: page_param)
  end

  def destroy
    conference_user = authorize ConferenceUser.find(params[:id])

    conference_user.destroy

    respond_to do |format|
      format.html { redirect_to(conference_users_path) }
    end
  end
end
