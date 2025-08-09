require 'application_system_test_case'

# Generated test cases
class CallForParticipationsSystemTest < ApplicationSystemTestCase
  setup do
    @conference = create(:conference, acronym: 'testconf')
    @orga = create(:conference_orga, conference: @conference)
    @conference.create_call_for_participation(
      start_date: 1.month.from_now,
      end_date: 2.months.from_now
    )
  end

  test 'orga can access CFP page' do
    sign_in_user(@orga.user)
    visit "/#{@conference.acronym}/call_for_participation"

    assert_content page, 'Call for Participation'
  end

  test 'orga can see CFP submitters interface link' do
    sign_in_user(@orga.user)
    visit "/#{@conference.acronym}/call_for_participation"

    assert_selector 'a[href*="testconf/cfp"]'
  end

  test 'orga can see edit CFP button' do
    sign_in_user(@orga.user)
    visit "/#{@conference.acronym}/call_for_participation"

    assert_selector 'a[href*="edit"]', text: 'edit'
  end

  test 'orga can see CFP dates when set' do
    sign_in_user(@orga.user)
    visit "/#{@conference.acronym}/call_for_participation"

    # Dates should be displayed since we set them in setup
    assert_content page, @conference.call_for_participation.start_date.year.to_s
  end

  test 'orga sees warning about empty conference days' do
    sign_in_user(@orga.user)
    visit "/#{@conference.acronym}/call_for_participation"

    assert_content page, 'Conference will not show up until days are added'
  end

  test 'orga sees warning about empty welcome text' do
    sign_in_user(@orga.user)
    visit "/#{@conference.acronym}/call_for_participation"

    assert_content page, 'Welcome Text'
  end
end
