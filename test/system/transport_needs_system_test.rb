require 'application_system_test_case'

# Generated test cases
class TransportNeedsSystemTest < ApplicationSystemTestCase
  setup do
    @conference = create(:three_day_conference_with_events_and_speakers)
    @conference.update!(transport_needs_enabled: true)
    @orga = create(:conference_orga, conference: @conference)
    @person = create(:person, email: 'speaker@example.com', public_name: 'Test Speaker')
  end

  test 'orga can view transport needs for person' do
    sign_in_user(@orga.user)
    visit "/#{@conference.acronym}/people/#{@person.id}/transport_needs"

    assert_content page, 'Transport needs'
  end

  test 'orga can create transport need for person' do
    sign_in_user(@orga.user)
    visit "/#{@conference.acronym}/people/#{@person.id}/transport_needs/new"

    # Fill in the transport need details
    fill_in 'At', with: @conference.days.first.start_date.since(4.hours)
    select 'Bus', from: 'Transport type'
    fill_in 'Seats', with: '1'
    fill_in 'Note', with: 'Needs assistance with luggage'

    click_on 'Create Transport need'

    assert_content page, 'Transport need was successfully added'
  end

  test 'orga can edit existing transport need' do
    transport_need = create(:transport_need,
      person: @person,
      conference: @conference,
      at: @conference.days.first.start_date.since(6.hours),
      transport_type: 'Bus',
      seats: 1,
      note: 'Original note'
    )

    sign_in_user(@orga.user)
    visit "/#{@conference.acronym}/people/#{@person.id}/transport_needs/#{transport_need.id}/edit"

    fill_in 'Note', with: 'Updated transportation note'
    click_on 'Update Transport need'

    assert_content page, 'Transport need was successfully updated'
  end

  test 'orga can view transport needs on person page' do
    transport_need = create(:transport_need,
      person: @person,
      conference: @conference,
      at: @conference.days.first.start_date.since(8.hours),
      transport_type: 'Bus',
      seats: 2,
      note: 'Test transport need'
    )

    sign_in_user(@orga.user)
    visit "/#{@conference.acronym}/people/#{@person.id}"

    # Should see the transport need listed
    assert_content page, 'Test transport need'
    assert_content page, 'Bus'
  end

  test 'transport needs are disabled when feature is off' do
    @conference.update!(transport_needs_enabled: false)

    sign_in_user(@orga.user)
    visit "/#{@conference.acronym}/people/#{@person.id}/transport_needs/new"

    assert_content page, 'Transport needs are not enabled for this conference'
  end

  test 'transport need form shows all fields' do
    sign_in_user(@orga.user)
    visit "/#{@conference.acronym}/people/#{@person.id}/transport_needs/new"

    assert_content page, 'Transport Need'
    assert_selector 'input[name*="at"]'
    assert_selector 'select[name*="transport_type"]'
  end
end
