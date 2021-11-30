require 'application_system_test_case'

class EditingEventsPeopleTest < ApplicationSystemTestCase
  setup do
    @conference = create(:three_day_conference_with_events)
    @event = @conference.events.last
    @user = create(:conference_reviewer, conference: @conference).user
    @admin = create(:admin_user)
  end

  test 'admin can add user to event' do
    sign_in_user(@admin)
    visit "/#{@conference.acronym}/events/#{@event.id}/edit_people"

    @user.reload

    assert_content page, 'Editing People'
    click_on 'Add person'
    find('input', id: 'filter').click
    fill_in 'filter', with: @user.person.email
    select 'Speaker'

    Capybara.using_wait_time(10) do
      assert_content page, @user.person.public_name
    end
    click_on 'Update event'

    assert_content page, 'Event was successfully updated.'
    assert_content page, @user.person.public_name
  end
end
