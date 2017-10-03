require 'test_helper'

class ConferencesControllerTest < ActionController::TestCase
  setup do
    create(:conference)
    create(:conference)
    @conference = create(:conference)
    login_as(:admin)
  end

  def conference_params
    @conference.attributes.except('id', 'created_at', 'updated_at')
  end

  def conference_attributes
    attribs = attributes_for(:conference)
    attribs[:timezone] = 'Hawaii'
    attribs.delete(:parent)
    attribs
  end

  def sub_conference_attributes
    attribs = attributes_for(:conference)
    attribs[:timezone] = 'Hawaii'
    attribs[:parent_id] = Conference.first.id
    attribs
  end

  test 'should list all' do
    get :index
    assert_response :success
  end

  test 'should show conference' do
    get :show, params: { conference_acronym: @conference.acronym }
    assert_response :success
  end

  test 'should get new' do
    get :new
    assert_response :success
  end

  test 'should create conference' do
    assert_difference('Conference.count') do
      post :create, params: { conference: attributes_for(:conference) }
    end
  end

  test 'should create conference without parent' do
    assert_difference('Conference.count') do
      post :create, params: { conference: conference_attributes }
    end
    assert_equal 'Hawaii', Conference.last.timezone
  end

  test 'should create sub conference' do
    assert_difference('Conference.count') do
      post :create, params: { conference: sub_conference_attributes }
    end
    assert_equal 'Berlin', Conference.last.timezone
  end

  test 'should get edit' do
    get :edit, params: { id: @conference.to_param, conference_acronym: @conference.acronym }
    assert_response :success
  end

  test 'should update conference' do
    new_acronym = @conference.acronym + '1'
    put :update, params: { conference: conference_params.merge(acronym: new_acronym), conference_acronym: @conference.acronym }
    assert_redirected_to edit_conference_path(conference_acronym: new_acronym)
  end

  test 'should get edit days' do
    get :edit_days, params: { conference_acronym: @conference.acronym }
    assert_response :success
  end

  test 'should add conference_day' do
    assert_difference('Day.count') do
      @conference.days << create(:day)
      put :update, params: { conference: conference_params, conference_acronym: @conference.acronym }
    end
  end

  test 'should create conference with feedback disabled' do
    assert_difference('Conference.count') do
      post :create, params: { conference: attributes_for(:conference, feedback_enabled: false) }
    end
  end

  test 'should get edit notification' do
    get :edit_notifications, params: { conference_acronym: @conference.acronym }
    assert_response :success
  end

  test 'should add notification' do
    params = {
      conference_acronym: @conference.acronym,
      conference: conference_params.merge(
        welcome_text: 'welcome',
        notifications_attributes: {
          '0' => {
            reject_body: 'reject body text',
            reject_subject: 'rejected subject',
            accept_body: 'accept body text',
            accept_subject: 'accepted subject',
            schedule_body: 'schedule body text',
            schedule_subject: 'schedule subject',
            locale: 'en'
          }
        }
      )
    }
    assert_difference('Notification.count') do
      put :update, params: params
    end
  end

  test 'should list all as JSON' do
    get :index, format: :json
    assert_response :success
    conferences = JSON.parse(response.body)['conferences']
    assert_equal 3, conferences.count
    assert_includes conferences[0].keys, 'daysCount'
    assert_includes conferences[0].keys, 'days'
  end

  test 'should show conference as JSON' do
    get :show, format: :json, params: { conference_acronym: @conference.acronym }
    assert_response :success
    conference = JSON.parse(response.body)
    assert_includes conference.keys, 'daysCount'
    assert_includes conference.keys, 'days'
  end

  test 'get default notification texts as JSON' do
    get :default_notifications, format: :json, params: { code: 'en', conference_acronym: @conference.acronym }
    assert_response :success
  end
end
