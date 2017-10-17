class ConferenceUsersController < BaseCrewController
  def index
    @users = policy_scope(ConferenceUser.all)
      .includes(user: :person)
      .order(:user_id, :role, :conference_id)
      .paginate(page: page_param)
  end

  def admins
    authorize User, :index?
    @users = User.all_admins.order(:email).paginate(page: page_param)
  end
end
