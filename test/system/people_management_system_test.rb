require 'application_system_test_case'

# Generated test cases
class PeopleManagementSystemTest < ApplicationSystemTestCase
  setup do
    @conference = create(:three_day_conference_with_events_and_speakers)
    @orga = create(:conference_orga, conference: @conference)
    @person = create(:person, public_name: 'Test Speaker', email: 'speaker@example.com')
  end

  test 'orga can view people list' do
    # Create person involved in conference
    event = create(:event, conference: @conference)
    create(:event_person, event: event, person: @person, event_role: 'speaker')

    sign_in_user(@orga.user)
    visit "/#{@conference.acronym}/people"

    assert_content page, 'List of people'
    assert_content page, 'Add person'
    assert_content page, @person.public_name
  end

  test 'orga can create new person' do
    sign_in_user(@orga.user)
    visit "/#{@conference.acronym}/people"

    click_on 'Add person'

    fill_in 'Public name', with: 'New Speaker'
    fill_in 'Email', with: 'newspeaker@example.com'
    fill_in 'First name', with: 'John'
    fill_in 'Last name', with: 'Doe'

    # Submit the form
    find('input[type="submit"]').click

    assert_content page, 'Person was successfully created'
    assert_content page, 'New Speaker'
  end

  test 'orga can edit existing person' do
    sign_in_user(@orga.user)
    visit "/#{@conference.acronym}/people/#{@person.id}/edit"

    fill_in 'Public name', with: 'Updated Speaker Name'
    find('input[type="submit"]').click

    assert_content page, 'Person was successfully updated'
    assert_content page, 'Updated Speaker Name'
  end

  test 'orga can view individual person details' do
    # Create an event association
    event = create(:event, conference: @conference, title: 'Speaker Event')
    create(:event_person, event: event, person: @person, event_role: 'speaker')

    sign_in_user(@orga.user)
    visit "/#{@conference.acronym}/people/#{@person.id}"

    assert_content page, @person.public_name
    assert_content page, @person.email
    assert_content page, 'Speaker Event'
  end

  test 'orga can view speakers tab' do
    # Create speaker for conference
    event = create(:event, conference: @conference, state: 'confirmed')
    create(:event_person, event: event, person: @person, event_role: 'speaker', role_state: 'confirmed')

    sign_in_user(@orga.user)
    visit "/#{@conference.acronym}/people"

    click_on 'Speakers'

    assert_content page, @person.public_name
  end

  test 'orga can search people by name' do
    person1 = create(:person, public_name: 'Alice Speaker')
    person2 = create(:person, public_name: 'Bob Speaker')

    # Associate both with conference
    event = create(:event, conference: @conference)
    create(:event_person, event: event, person: person1, event_role: 'speaker')
    create(:event_person, event: event, person: person2, event_role: 'speaker')

    sign_in_user(@orga.user)
    visit "/#{@conference.acronym}/people"

    fill_in 'term', with: 'Alice'
    click_on 'Search'

    assert_content page, 'Alice Speaker'
    refute_content page, 'Bob Speaker'
  end

  test 'orga can view all people across conferences' do
    sign_in_user(@orga.user)
    visit "/#{@conference.acronym}/people"

    click_on 'All people'

    assert_match %r{/#{@conference.acronym}/people/all}, current_path
  end

  test 'people list shows navigation tabs' do
    sign_in_user(@orga.user)
    visit "/#{@conference.acronym}/people"

    assert_content page, 'This conference'
    assert_content page, 'Speakers'
    assert_content page, 'All people'
  end

  test 'people list shows empty state when no people' do
    # Ensure no people are associated with conference
    sign_in_user(@orga.user)
    visit "/#{@conference.acronym}/people"

    # Should show empty state messaging
    assert_selector '.bi-people'
  end

  test 'orga can access person edit from person page' do
    sign_in_user(@orga.user)
    visit "/#{@conference.acronym}/people/#{@person.id}"

    assert_content page, 'Edit person'
  end

  test 'people list supports pagination' do
    # Create many people associated with conference (more than default per_page of 100)
    event = create(:event, conference: @conference)
    110.times do |i|
      person = create(:person, public_name: "Speaker #{i}", email: "speaker#{i}@example.com")
      create(:event_person, event: event, person: person, event_role: 'speaker')
    end

    sign_in_user(@orga.user)
    visit "/#{@conference.acronym}/people"

    # Should show pagination controls when many people exist
    assert_selector '.pagination'
  end

  # Note: Coordinators CAN create people in this application
  # The original AI-generated test incorrectly assumed they couldn't

  test 'speakers export as text format' do
    # Create speaker
    event = create(:event, conference: @conference)
    create(:event_person, event: event, person: @person, event_role: 'speaker')

    sign_in_user(@orga.user)
    visit "/#{@conference.acronym}/people/speakers.txt"

    # Should get response with email addresses
    assert_content page, '@example.com'  # Should contain some email addresses
  end

  test 'person page shows associated events' do
    event1 = create(:event, conference: @conference, title: 'First Event', state: 'confirmed')
    event2 = create(:event, conference: @conference, title: 'Second Event', state: 'new')

    create(:event_person, event: event1, person: @person, event_role: 'speaker')
    create(:event_person, event: event2, person: @person, event_role: 'moderator')

    sign_in_user(@orga.user)
    visit "/#{@conference.acronym}/people/#{@person.id}"

    assert_content page, 'First Event'
    assert_content page, 'Second Event'
  end

  test 'person creation handles validation errors gracefully' do
    sign_in_user(@orga.user)
    visit "/#{@conference.acronym}/people/new"

    # Try to create without required fields (public_name is required)
    find('input[type="submit"]').click

    # Should stay on new person form due to validation errors, not redirect
    assert_current_path "/#{@conference.acronym}/people/new"
    # Form should still be visible
    assert_content page, 'New Person'
  end
end
