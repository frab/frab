require 'application_system_test_case'

# Generated test cases
class ConferenceRoomsTracksSystemTest < ApplicationSystemTestCase
  setup do
    @conference = create(:conference, acronym: 'testconf')
    @orga = create(:conference_orga, conference: @conference)
  end

  test 'orga can access rooms management' do
    sign_in_user(@orga.user)
    visit "/#{@conference.acronym}/conference/edit_rooms"

    assert_content page, 'rooms'
  end

  test 'orga can access tracks management' do
    sign_in_user(@orga.user)
    visit "/#{@conference.acronym}/conference/edit_tracks"

    assert_content page, 'tracks'
  end

  test 'rooms management shows empty state when no rooms exist' do
    sign_in_user(@orga.user)
    visit "/#{@conference.acronym}/conference/edit_rooms"

    assert_selector '.blank-slate'
  end

  test 'tracks management shows empty state when no tracks exist' do
    sign_in_user(@orga.user)
    visit "/#{@conference.acronym}/conference/edit_tracks"

    assert_selector '.blank-slate'
  end

  test 'rooms management shows existing rooms' do
    room = create(:room, conference: @conference, name: 'Main Hall', size: 100)
    sign_in_user(@orga.user)
    visit "/#{@conference.acronym}/conference/edit_rooms"

    assert_field 'Name', with: 'Main Hall'
    assert_field 'Size', with: '100'
  end

  test 'tracks management shows existing tracks' do
    track = create(:track, conference: @conference, name: 'Security')
    sign_in_user(@orga.user)
    visit "/#{@conference.acronym}/conference/edit_tracks"

    assert_field 'Name (en)', with: 'Security'
  end
end
