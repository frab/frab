require 'test_helper'

class EditingEventsPeopleTest < FeatureTest
  setup do
    @conference = create(:three_day_conference_with_events)
    @event = @conference.events.last
    @user = create(:conference_reviewer, conference: @conference).user
    @admin = create(:admin_user)
  end

  it 'admin can add user to event', js: true do
    sign_in_user(@admin)
    visit "/#{@conference.acronym}/events/#{@event.id}/edit_people"

    assert_content page, 'Editing People'
    click_on 'Add person'
    find('input', id: 'filter').click()
    find('input', id: 'filter').send_keys("#{@user.id}")
    select 'Speaker'
    click_on 'Update event'
    assert_content page, 'Event was successfully updated.'
    assert_content page, @user.person.public_name
  end
end
