require 'test_helper'

class OrgaAddsConferenceUserTest < FeatureTest
  setup do
    @conference = create(:three_day_conference)
    @orga = create(:conference_orga, conference: @conference)
    @crew_user = create(:crew_user)
    @person = @crew_user.person
  end

  it 'adds crew user as orga', js: true do
    sign_in_user(@orga.user)
    visit "/#{@conference.acronym}/people/all"
    assert_content page, @person.email
    within('tr', text: @person.email) do
      click_on('Edit account')
    end
    assert_content page, "Edit Account: #{@person.public_name}"

    click_on 'Add conference user'
    select 'Organisator', from: 'Role'
    select @conference.acronym, from: 'Conference'
    click_on 'Update User'
    assert @crew_user.is_crew?
    assert @crew_user.is_orga_of?(@conference)
  end
end
