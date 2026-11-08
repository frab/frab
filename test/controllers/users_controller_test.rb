require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  setup do
    @conference = create(:conference)
    @person = create(:person)
    @user = create(:user, person: create(:person))
    login_as(:admin)
  end

  def user_params(user_type = :user)
    user_params = attributes_for(user_type).merge(password: 'frab123', password_confirmation: 'frab123')
    user_params.delete(:confirmed_at)
    user_params.delete(:sign_in_count)
    user_params
  end

  test 'should get new' do
    get :new, params: { person_id: @person.id, conference_acronym: @conference.acronym }
    assert_response :success
  end

  test 'should create user' do
    assert_difference('User.count') do
      post :create, params: { user: user_params, person_id: @person.id, conference_acronym: @conference.acronym }
    end

    assert_redirected_to edit_person_user_path(@person)
  end

  test 'should get edit' do
    get :edit, params: { person_id: @user.person.id, conference_acronym: @conference.acronym }
    assert_response :success
  end

  test 'should update user' do
    put :update, params: { user: { id: @user.id, email: 'admin@example.org' }, person_id: @user.person.id, conference_acronym: @conference.acronym }
    assert_redirected_to edit_crew_user_path(@user.person)
    get :edit, params: { person_id: @user.person.id, conference_acronym: @conference.acronym }
    assert_equal 'User was successfully updated.', flash['notice']
    assert_response :success
  end

  test 'should update user password' do
    put :update, params: { user: { id: @user.id, password: 'test123', password_confirmation: 'test123' }, person_id: @user.person.id, conference_acronym: @conference.acronym }
    assert_redirected_to edit_crew_user_path(@user.person)
    get :edit, params: { person_id: @user.person.id, conference_acronym: @conference.acronym }
    assert_response :success
  end

  test 'should create crew user' do
    assert_difference('User.count') do
      post :create, params: {
        user: user_params(:crew_user),
        person_id: @person.id,
        conference_acronym: @conference.acronym
      }
    end
  end

  test 'should change users role' do
    @user.role = 'crew'
    put :update, params: { user: { id: @user.id, role: 'crew' }, person_id: @user.person.id, conference_acronym: @conference.acronym }
    @user.reload
    assert_equal 'crew', @user.role
  end

  test 'should add conference user to existing crew user' do
    @user = create(:crew_user, person: create(:person))
    user_attributes = { id: @user.id, role: 'crew' }
    user_attributes['conference_users_attributes'] = {
      '0' => attributes_for(:conference_user, role: 'reviewer', conference_id: @conference.id)
    }
    assert_difference('ConferenceUser.count') do
      put :update, params: {
        user: user_attributes,
        person_id: @user.person.id,
        conference_acronym: @conference.acronym
      }
    end
    assert_redirected_to edit_crew_user_path(@user.person)
  end

  # --- Conference-role privilege escalation (issue #1053) ---

  def crew_with(conference_role, conference: @conference)
    user = create(:crew_user, person: create(:person))
    # Build the join row directly: the :conference_user factory's after(:build)
    # hook replaces any passed-in user with a fresh one.
    ConferenceUser.create!(user: user, conference: conference, role: conference_role)
    user
  end

  def grant_attributes(conference, role: 'orga')
    { '0' => { role: role, conference_id: conference.id } }
  end

  test 'reviewer cannot self-grant orga on their own conference' do
    reviewer = crew_with('reviewer')
    sign_in reviewer
    assert_no_difference('ConferenceUser.where(role: "orga").count') do
      put :update, params: {
        user: { id: reviewer.id, conference_users_attributes: grant_attributes(@conference) },
        person_id: reviewer.person.id
      }
    end
    assert_not reviewer.reload.is_orga_of?(@conference)
  end

  test 'reviewer cannot self-grant orga on an unrelated conference' do
    other = create(:conference)
    reviewer = crew_with('reviewer')
    sign_in reviewer
    assert_no_difference('ConferenceUser.count') do
      put :update, params: {
        user: { id: reviewer.id, conference_users_attributes: grant_attributes(other) },
        person_id: reviewer.person.id
      }
    end
    assert_not reviewer.reload.is_orga_of?(other)
  end

  test 'coordinator cannot self-grant orga' do
    other = create(:conference)
    coordinator = crew_with('coordinator')
    sign_in coordinator
    assert_no_difference('ConferenceUser.where(role: "orga").count') do
      put :update, params: {
        user: { id: coordinator.id, conference_users_attributes: grant_attributes(other) },
        person_id: coordinator.person.id
      }
    end
    assert_not coordinator.reload.is_orga_of?(other)
  end

  test 'crew user with no conference role cannot self-grant orga' do
    user = create(:crew_user, person: create(:person))
    sign_in user
    assert_no_difference('ConferenceUser.count') do
      put :update, params: {
        user: { id: user.id, conference_users_attributes: grant_attributes(@conference) },
        person_id: user.person.id
      }
    end
    assert_not user.reload.is_orga_of?(@conference)
  end

  test 'orga cannot grant orga on a conference they do not organize' do
    other = create(:conference)
    orga = crew_with('orga')
    sign_in orga
    assert_no_difference('ConferenceUser.count') do
      put :update, params: {
        user: { id: orga.id, conference_users_attributes: grant_attributes(other) },
        person_id: orga.person.id
      }
    end
    assert_not orga.reload.is_orga_of?(other)
  end

  test 'orga can create a crew account with a role on a conference they organize' do
    orga = crew_with('orga')
    sign_in orga
    person = create(:person)
    assert_difference('ConferenceUser.count', 1) do
      post :create, params: {
        user: user_params(:crew_user).merge(conference_users_attributes: grant_attributes(@conference, role: 'reviewer')),
        person_id: person.id,
        conference_acronym: @conference.acronym
      }
    end
    assert person.reload.user.has_role?(@conference, 'reviewer')
  end

  test 'orga can change a crew role on a conference they organize' do
    orga = crew_with('orga')
    member = crew_with('reviewer')
    row = member.conference_users.reload.first
    sign_in orga
    put :update, params: {
      user: { id: member.id, conference_users_attributes: {
        '0' => { id: row.id, role: 'coordinator', conference_id: @conference.id }
      } },
      person_id: member.person.id
    }
    assert_equal 'coordinator', row.reload.role
  end

  test 'orga cannot change credentials or role of a user from another conference' do
    other = create(:conference)
    orga = crew_with('orga')
    stranger = crew_with('reviewer', conference: other)
    old_password = stranger.encrypted_password
    sign_in orga
    put :update, params: {
      user: { id: stranger.id, email: 'taken@example.org',
              password: 'hijacked123', password_confirmation: 'hijacked123',
              role: 'submitter' },
      person_id: stranger.person.id
    }
    stranger.reload
    assert_equal old_password, stranger.encrypted_password # password not hijacked
    assert_nil stranger.unconfirmed_email                  # email change not even pending
    assert_equal 'crew', stranger.role                     # global role untouched
  end

  test 'orga can onboard a user from another conference onto their own conference' do
    other = create(:conference)
    orga = crew_with('orga')
    stranger = crew_with('reviewer', conference: other)
    sign_in orga
    assert_difference('ConferenceUser.count', 1) do
      put :update, params: {
        user: { id: stranger.id, conference_users_attributes: grant_attributes(@conference, role: 'reviewer') },
        person_id: stranger.person.id
      }
    end
    assert stranger.reload.has_role?(@conference, 'reviewer')
    assert stranger.has_role?(other, 'reviewer')
  end

  test 'orga can change the password of a user affiliated only with their own conference' do
    orga = crew_with('orga')
    member = crew_with('reviewer')
    sign_in orga
    put :update, params: {
      user: { id: member.id, password: 'newsecret123', password_confirmation: 'newsecret123' },
      person_id: member.person.id
    }
    assert member.reload.valid_password?('newsecret123')
  end

  test 'orga cannot destroy a foreign grant by spoofing its conference_id' do
    other = create(:conference)
    orga = crew_with('orga')
    member = crew_with('reviewer', conference: other)
    row = member.conference_users.reload.first
    sign_in orga
    assert_no_difference('ConferenceUser.count') do
      put :update, params: {
        user: { id: member.id, conference_users_attributes: {
          '0' => { id: row.id, conference_id: @conference.id, _destroy: '1' }
        } },
        person_id: member.person.id
      }
    end
  end

  test 'orga cannot move a foreign grant by spoofing its conference_id' do
    other = create(:conference)
    orga = crew_with('orga')
    member = crew_with('reviewer', conference: other)
    row = member.conference_users.reload.first
    sign_in orga
    put :update, params: {
      user: { id: member.id, conference_users_attributes: {
        '0' => { id: row.id, conference_id: @conference.id, role: 'reviewer' }
      } },
      person_id: member.person.id
    }
    assert_equal other.id, row.reload.conference_id
  end

  test 'orga cannot move their own grant onto a conference they do not organize' do
    other = create(:conference)
    orga = crew_with('orga')
    row = orga.conference_users.reload.first
    sign_in orga
    put :update, params: {
      user: { id: orga.id, conference_users_attributes: {
        '0' => { id: row.id, conference_id: other.id, role: 'orga' }
      } },
      person_id: orga.person.id
    }
    assert_equal @conference.id, row.reload.conference_id
    assert_not orga.reload.is_orga_of?(other)
  end

  test 'orga cannot create a new account with orga on an unrelated conference' do
    other = create(:conference)
    orga = crew_with('orga')
    sign_in orga
    person = create(:person)
    post :create, params: {
      user: user_params(:crew_user).merge(conference_users_attributes: grant_attributes(other)),
      person_id: person.id,
      conference_acronym: @conference.acronym
    }
    assert_nil ConferenceUser.joins(:user).where(users: { id: person.user&.id }, conference: other).first
  end

  test 'visiting own edit page does not destroy a reviewer conference role' do
    reviewer = crew_with('reviewer')
    sign_in reviewer
    assert_no_difference('ConferenceUser.count') do
      get :edit, params: { person_id: reviewer.person.id, conference_acronym: @conference.acronym }
    end
    assert reviewer.reload.has_role?(@conference, 'reviewer')
  end
end
