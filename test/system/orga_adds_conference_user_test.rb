require 'application_system_test_case'

class OrgaAddsConferenceUserTest < ApplicationSystemTestCase
  setup do
    @conference = create(:three_day_conference)
    @orga = create(:conference_orga, conference: @conference)
    @crew_user = create(:crew_user)
    @person = @crew_user.person
  end

  test 'adds crew user as orga' do
    sign_in_user(@orga.user)
    visit "/#{@conference.acronym}/people/all"
    assert_content page, @person.email
    within('tr', text: @person.email) do
      find('a[data-bs-content*="Edit account"]').click
    end
    assert_content page, "Edit Account: #{@person.public_name}"

    click_on 'Add conference user'
    select 'Organisator', from: 'Role'
    select @conference.acronym, from: 'Conference'
    click_on 'Update User'

    assert_content page, 'successfully updated'
    assert @crew_user.is_crew?
    assert @crew_user.is_orga_of?(@conference)
  end
end
