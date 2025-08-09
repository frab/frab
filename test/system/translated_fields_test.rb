require 'application_system_test_case'

class TranslatedFieldsTest < ApplicationSystemTestCase
  setup do
    @conference = create(:multilingual_conference)
    @admin = create(:admin_user)
    sign_in_user(@admin)
  end

  test 'add track translation to conference' do
    assert_content page, 'Conferences'
    click_on 'Show'
    click_on 'More'
    click_on 'Settings'
    click_on 'Tracks'

    assert_content page, 'Add track'

    click_on 'Add track'
    assert_content page, '* English'
    assert_content page, 'German'

    # id is something like: conference_tracks_attributes_1638123861291_name_en
    fill_in 'Name (de)', with: 'Track 1 de'
    fill_in 'Name (en)', with: 'Track 1 en'
    find('input[type="color"]', match: :first).set('#ff0000')

    click_on 'Add track'

    # Fill in the second track's fields (the one that was just added)
    within all('.nested-fields').last do
      fill_in 'Name (en)', with: 'Track 2 en'
      fill_in 'Name (de)', with: 'Track 2 de'
      find('input[type="color"]').set('#00ff00')
    end

    click_on 'Update conference'
    assert_content page, 'Conference was successfully updated.'

    assert_equal 2, @conference.tracks.count

    click_on 'Tracks'
    assert page.has_field? 'conference_tracks_attributes_1_name_de', with: 'Track 2 de'
    assert page.has_field? 'Name', with: 'Track 2 en'
    assert page.has_field? 'Name', with: 'Track 1 de'
    assert page.has_field? 'Name', with: 'Track 1 en'
  end

  test 'edit person description' do
    visit "/#{@conference.acronym}/people"
    find('i.bi-pencil-square', match: :first).click

    within find('.card', text: 'Bio') do
      fill_in 'Abstract (en)', with: 'english abstract'
      fill_in 'Description (en)', with: 'english description'
      fill_in 'Abstract (de)', with: 'german abstract'
      fill_in 'Description (de)', with: 'german description'
    end

    click_on 'Update profile'
    assert_content page, 'Person was successfully updated.'

    assert_content page, 'english abstract'
    assert_content page, 'english description'
  end

  test 'edit event description' do
    visit "/#{@conference.acronym}/events"
    find('i.bi-pencil-square', match: :first).click

    within find('.card', text: 'Basic Information') do
      fill_in 'Title (de)', with: 'german title'
      fill_in 'Title (en)', with: 'english title'
      fill_in 'Subtitle (en)', with: 'english subtitle'
      fill_in 'Subtitle (de)', with: 'german subtitle'
    end

    within find('.card', text: 'Detailed Description') do
      fill_in 'Summary (en)', with: 'english summary'
      fill_in 'Description (en)', with: 'english description'
      fill_in 'Summary (de)', with: 'german summary'
      fill_in 'Description (de)', with: 'german description'
    end

    click_on 'Update event'
    assert_content page, 'Event was successfully updated.'

    assert_content page, 'english title'
    assert_content page, 'english subtitle'
    assert_content page, 'english summary'
    assert_content page, 'english description'
  end
end
