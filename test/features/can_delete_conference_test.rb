require 'test_helper'

class CanDeleteConferenceTest < FeatureTest
  setup do
    @conference = create(:three_day_conference)
    @admin = create(:admin_user)
  end

  it 'can delete conference', js: true do
    sign_in_user(@admin)
    visit "/conferences?term=#{@conference.acronym}"
    assert_content page, @conference.acronym

    find('tr', text: @conference.title).find('a', text: 'destroy').click

    assert_no_content page, @conference.acronym
  end
end
