class UserConferenceContext
  def initialize(user:, conference:)
    @user = user
    @conference = conference
  end
  attr_accessor :user, :conference
end
