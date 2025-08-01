require 'application_system_test_case'

class CanDeleteConferenceTest < ApplicationSystemTestCase
  setup do
    @conference = create(:three_day_conference)
    @admin = create(:admin_user)
  end

  test 'can delete conference' do
    sign_in_user(@admin)
    visit "/conferences?term=#{@conference.acronym}"
    assert_content page, @conference.acronym

    accept_alert do
      find('tr', text: @conference.title).find('button i.bi-trash').ancestor('button').click
    end

    assert_no_content page, @conference.acronym
  end
end
