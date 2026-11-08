require 'test_helper'

# Full-stack coverage for the conference-role privilege escalation reported in
# issue #1053: the nested conference_users_attributes accepted by
# UsersController#create and #update must never let a crew member grant a role
# on a conference they do not organize.
class ConferenceRoleEscalationTest < PunditControllerTest
  setup do
    @acronym = create_conference
    create_other_conference
  end

  # --- sink 1: a crew member below orga may not escalate themselves ---

  def test_reviewer_cannot_self_grant_orga
    reviewer = create(:conference_reviewer, conference: @conference).user
    sign_in reviewer
    assert_no_difference 'ConferenceUser.where(role: "orga").count' do
      patch "/user/#{reviewer.person.id}", params: escalation_params(@other_conference)
    end
    assert_not reviewer.reload.is_orga_of?(@other_conference)
    assert_not reviewer.is_orga_of?(@conference)
  end

  def test_coordinator_cannot_self_grant_orga
    coordinator = create(:conference_coordinator, conference: @conference).user
    sign_in coordinator
    assert_no_difference 'ConferenceUser.where(role: "orga").count' do
      patch "/user/#{coordinator.person.id}", params: escalation_params(@other_conference)
    end
    assert_not coordinator.reload.is_orga_of?(@other_conference)
  end

  def test_crew_without_conference_role_cannot_self_grant_orga
    user = create(:crew_user)
    sign_in user
    assert_no_difference 'ConferenceUser.count' do
      patch "/user/#{user.person.id}", params: escalation_params(@conference)
    end
    assert_not user.reload.is_orga_of?(@conference)
  end

  # --- sink 2 + isolation: an orga is bound to the conferences they organize ---

  def test_orga_cannot_self_grant_orga_on_foreign_conference
    orga = create(:conference_orga, conference: @conference).user
    sign_in orga
    assert_no_difference 'ConferenceUser.count' do
      patch "/user/#{orga.person.id}", params: escalation_params(@other_conference)
    end
    assert_not orga.reload.is_orga_of?(@other_conference)
  end

  def test_orga_can_onboard_user_from_another_conference
    orga = create(:conference_orga, conference: @conference).user
    membership = create(:conference_reviewer, conference: @other_conference)
    stranger = membership.user
    sign_in orga
    assert_difference 'ConferenceUser.count', 1 do
      patch "/user/#{stranger.person.id}", params: {
        user: { conference_users_attributes: { '0' => { role: 'reviewer', conference_id: @conference.id } } }
      }
    end
    assert stranger.reload.has_role?(@conference, 'reviewer')
    assert stranger.has_role?(@other_conference, 'reviewer')
  end

  def test_orga_cannot_create_crew_with_orga_on_foreign_conference
    orga = create(:conference_orga, conference: @conference).user
    person = create(:person)
    sign_in orga
    post "/#{@acronym}/people/#{person.id}/user", params: {
      user: new_crew_params('foreign-grant@example.org').merge(
        conference_users_attributes: { '0' => { role: 'orga', conference_id: @other_conference.id } }
      )
    }
    assert_nil person.reload.user&.conference_users&.find_by(conference: @other_conference)
  end

  # --- legitimate crew management on a conference the orga organizes ---

  def test_orga_can_change_role_on_their_conference
    orga = create(:conference_orga, conference: @conference).user
    membership = create(:conference_reviewer, conference: @conference)
    sign_in orga
    patch "/user/#{membership.user.person.id}", params: {
      user: { conference_users_attributes: {
        '0' => { id: membership.id, role: 'coordinator', conference_id: @conference.id }
      } }
    }
    assert_equal 'coordinator', membership.reload.role
  end

  def test_orga_can_create_crew_with_role_on_their_conference
    orga = create(:conference_orga, conference: @conference).user
    person = create(:person)
    sign_in orga
    assert_difference 'ConferenceUser.count', 1 do
      post "/#{@acronym}/people/#{person.id}/user", params: {
        user: new_crew_params('new-crew@example.org').merge(
          conference_users_attributes: { '0' => { role: 'reviewer', conference_id: @conference.id } }
        )
      }
    end
    assert person.reload.user.has_role?(@conference, 'reviewer')
  end

  private

  def escalation_params(conference, role: 'orga')
    { user: { conference_users_attributes: { '0' => { role: role, conference_id: conference.id } } } }
  end

  def new_crew_params(email)
    { email: email, password: 'frab123frab', password_confirmation: 'frab123frab', role: 'crew' }
  end
end
