require 'test_helper'

class Cfp::EventsControllerTest < ActionController::TestCase
  setup do
    @event = create(:event)
    @conference = @event.conference
    @user = login_as(:submitter)
  end

  def event_params
    @event.attributes.slice(
      'title',
      'subtitle',
      'event_type',
      'time_slots',
      'language',
      'abstract',
      'description',
      'logo_content_type',
      'track_id',
      'submission_note',
      'event_feedbacks_count',
      'do_not_record',
      'recording_license',
      'target_audience_experience',
      'tech_rider'
    )
  end

  test 'should get new' do
    get :new, params: { conference_acronym: @conference.acronym }
    assert_response :success
  end

  test 'should create event' do
    assert_difference('Event.count') do
      post :create, params: { event: event_params, conference_acronym: @conference.acronym }
    end
    assert_response :redirect
  end

  test 'should get edit' do
    create(:event_person, event: @event, person: @user.person)
    get :edit, params: { id: @event.to_param, conference_acronym: @conference.acronym }
    assert_response :success
  end

  test 'should update event' do
    create(:event_person, event: @event, person: @user.person)
    put :update, params: { id: @event.to_param, event: event_params, conference_acronym: @conference.acronym }
    assert_response :redirect
  end

  def setup_unconfirmed(person)
    @event.update(state: 'unconfirmed')
    event_person = create(:event_person, event: @event, person: person)
    event_person.generate_token!
    event_person
  end

  test 'should not confirm on get but redirect to confirm page' do
    event_person = setup_unconfirmed(@user.person)
    get :confirm, params: { conference_acronym: @conference.acronym, id: @event.id, token: event_person.confirmation_token }
    assert_response :success
    assert_equal 'unconfirmed', @event.reload.state
  end

  test 'should confirm event for logged in user' do
    event_person = setup_unconfirmed(@user.person)
    post :confirm, params: { conference_acronym: @conference.acronym, id: @event.id, token: event_person.confirmation_token }
    assert_redirected_to cfp_person_path
    assert_equal 'confirmed', @event.reload.state
  end

  test 'should confirm event for logged in user without requiring a token' do
    setup_unconfirmed(@user.person)
    post :confirm, params: { conference_acronym: @conference.acronym, id: @event.id }
    assert_redirected_to cfp_person_path
    assert_equal 'confirmed', @event.reload.state
    assert_nil session[:user_id]
  end

  test 'should confirm event and thank user' do
    log_out
    event_person = setup_unconfirmed(@user.person)
    post :confirm, params: { conference_acronym: @conference.acronym, id: @event.id, token: event_person.confirmation_token }
    assert_redirected_to new_user_session_path
    assert_equal 'confirmed', @event.reload.state
    assert_nil session[:user_id]
  end

  test 'should confirm event if person does not have a user account' do
    log_out
    event_person = setup_unconfirmed(create(:person))
    post :confirm, params: { conference_acronym: @conference.acronym, id: @event.id, token: event_person.confirmation_token }
    assert_redirected_to new_user_session_path
    assert_equal 'confirmed', @event.reload.state
    assert_nil session[:user_id]
  end

  test 'should redirect if confirm token was invalid' do
    log_out
    get :confirm, params: { conference_acronym: @conference.acronym, id: @event.id, token: '%' }
    assert_redirected_to cfp_person_path
    refute_equal 'confirmed', @event.reload.state
    assert_nil session[:user_id]
  end

  # Event locking CFP controller tests
  test 'should not update locked event' do
    @event.update!(locked: true)
    create(:event_person, event: @event, person: @user.person)
    original_title = @event.title
    
    modified_params = event_params.merge('title' => 'New Title')
    put :update, params: { id: @event.to_param, event: modified_params, conference_acronym: @conference.acronym }
    
    assert_redirected_to edit_cfp_event_path(@event)
    assert_equal flash[:error], I18n.t('cfp.event_locked_cannot_update')
    
    @event.reload
    assert_equal original_title, @event.title
  end

  test 'should update unlocked event normally' do
    @event.update!(locked: false)
    create(:event_person, event: @event, person: @user.person)
    original_title = @event.title
    
    modified_params = event_params.merge('title' => 'New Title')
    put :update, params: { id: @event.to_param, event: modified_params, conference_acronym: @conference.acronym }
    
    assert_response :redirect
    refute_equal flash[:error], I18n.t('cfp.event_locked_cannot_update')
    
    @event.reload
    assert_equal 'New Title', @event.title
  end

  test 'should still allow withdraw for locked event' do
    @event.update!(locked: true, state: 'unconfirmed')
    create(:event_person, event: @event, person: @user.person)
    
    put :withdraw, params: { id: @event.to_param, conference_acronym: @conference.acronym }
    
    assert_response :redirect
    @event.reload
    assert_equal 'withdrawn', @event.state
  end
end
