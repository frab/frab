module CrewRolesHelper
  def assert_ability_denied
    assert_response :redirect
    assert_equal I18n.t(:"ability.denied"), flash[:notice]
  end

  def create_conference
    @event = create :event
    @conference = @event.conference
    create :call_for_participation, conference: @conference

    @submitter_user = create :user
    create :event_person, person: @submitter_user.person, event: @event
    @rating = create :event_rating, event: @event, rating: 4.0

    @conference.acronym
  end

  def create_other_conference
    @other_conference = create :three_day_conference_with_events_and_speakers, acronym: 'other'
    @other_event = @other_conference.events.first
  end
end
