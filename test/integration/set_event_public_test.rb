require 'test_helper'

class SetEventPublicTest < ActionDispatch::IntegrationTest
  setup do
    @conference = create :three_day_conference
    @event = create :event, conference: @conference
    @conference_user = FactoryGirl.create :conference_orga, conference: @conference
    sign_in(@conference_user.user)
  end

  test "can set event to public" do
    @event.public = true
    put "/#{@conference.acronym}/events/#{@event.id}", event: { public: true }
    assert_redirected_to event_path(assigns(:event))

    get "/#{@conference.acronym}/events/#{@event.id}"
    assert_select '#public' do
      assert_select 'input[checked]', true
    end

    get "/#{@conference.acronym}/events/#{@event.id}/edit"
    assert_select '#event_public' do
      assert_select 'input[checked]', true
    end
  end

  test "can set event to private" do
    @event.public = false
    put "/#{@conference.acronym}/events/#{@event.id}", event: { public: false }
    assert_redirected_to event_path(assigns(:event))

    get "/#{@conference.acronym}/events/#{@event.id}"
    assert_select '#public' do
      assert_select 'input[checked]', false
    end

    get "/#{@conference.acronym}/events/#{@event.id}/edit"
    assert_select '#event_public' do
      assert_select 'input[checked]', false
    end
  end
end
