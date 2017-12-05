require 'test_helper'

class EditingUsersTest < FeatureTest
  setup do
    @conference = create(:three_day_conference)
    @admin = create(:admin_user)
    @person = create(:person, public_name: 'FakeName')
  end

  it 'creates and makes user into crew', js: true do
    sign_in_user(@admin)
    visit "/#{@conference.acronym}/people/all"
    assert_content page, @person.email
    within('tr', text: @person.email) do
      click_on('Sign Up')
    end
    assert_content page, "Create account for #{@person.public_name}"

    fill_in 'Email', with: @person.email
    fill_in 'Password', with: 'frab123'
    fill_in 'Password confirmation', with: 'frab123'
    click_on 'Create User'
    assert_content page, @person.public_name
    assert_content page, "Edit Account: #{@person.public_name}"

    choose('Crew')
    click_on 'Update User'
    assert_content page, "Edit Account: #{@person.public_name}"
    assert_content page, 'Admin'

    click_on 'Add conference user'
    select 'Organisator', from: 'Role'
    select @conference.acronym, from: 'Conference'
    click_on 'Update User'
    @person.reload
    assert @person.user.is_crew?
    assert @person.user.is_orga_of?(@conference)
  end
end
