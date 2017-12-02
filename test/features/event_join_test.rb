require 'test_helper'

class EventJoinTest < FeatureTest
  setup do
    @conference = create(:three_day_conference_with_events)
    @event = @conference.events.last
    create(:call_for_participation, conference: @conference)

    @user = create(:cfp_user)
    create(:event_person, event: @event, person: @user.person, role_state: 'confirmed')
  end

  test 'can find an invite token in a new event' do
    sign_in_user(@user)
    visit edit_cfp_event_path(id: @event.id, conference_acronym: @conference.acronym)
    assert_content page, @event.invite_token
    visit cfp_events_join_path(token: @event.invite_token, conference_acronym: @conference.acronym)
    assert_content page, @event.subtitle
    visit cfp_events_join_path(token: 'X', conference_acronym: @conference.acronym)
    assert_content page, 'unknown'
  end

  test 'can join an event ' do
    join_user = create(:cfp_user)
    sign_in_user(join_user)
    assert_equal @event.speaker_count, 1

    visit cfp_events_join_path(token: @event.invite_token, conference_acronym: @conference.acronym)
    click_on('Join event')
    assert_content page, 'added as speaker'
    assert_equal @event.speakers.count, 2

    visit cfp_events_join_path(token: @event.invite_token, conference_acronym: @conference.acronym)
    click_on('Join event')
    assert_content page, 'already were a speaker'
    assert_equal @event.speakers.count, 2
  end

  test 'can not join an event after hard deadline' do
    join_user = create(:cfp_user)
    sign_in_user(join_user)

    @conference.call_for_participation.update(hard_deadline: Date.yesterday)

    visit cfp_events_join_path(token: @event.invite_token, conference_acronym: @conference.acronym)
    assert_content page, 'deadline for submitting events is over'
    assert_equal @event.speakers.count, 1
  end
end
