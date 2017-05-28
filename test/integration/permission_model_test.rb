require "test_helper"

class PermissionModelTest < ActionDispatch::IntegrationTest

  setup do
    @acronym = create_conference
  end

  def test_submitter_can_use_cfp
    @user = create(:user)
    sign_in(@user)
    use_own_cfp_interface
  end

  # it 'cannot edit other user, person, event or conference' do
  # end

  def test_crew_can_use_cfp
    @user = create(:crew_user)
    sign_in(@user)
    use_own_cfp_interface
  end

  private

  def create_conference
    @event = create :event
    @conference = @event.conference
    create :call_for_participation, conference: @conference
    @conference.acronym
  end

  def use_own_cfp_interface
    get "/#{@acronym}/cfp/person/availability/new"
    assert_response :success
    patch "/#{@acronym}/cfp/person/availability", params: {}
    assert_response :redirect
    get "/#{@acronym}/cfp/person/edit"
    assert_response :success
    post "/#{@acronym}/cfp/person", params: { person: { email_public: 1 } }
    assert_response :redirect
    get "/#{@acronym}/cfp/user/edit"
    assert_response :success
    patch "/#{@acronym}/cfp/user", params: { user: { password: 'frab123', password_confirmation: 'frab123' } }
    assert_response :redirect
  end
end
