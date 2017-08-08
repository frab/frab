require 'test_helper'

class EditingUsersTest < Capybara::Rails::TestCase
  setup do
    @conference = create(:three_day_conference)
    @admin = create(:user, role: 'admin', password: 'frab123')
    @person = create(:person, public_name: 'FakeName')
    sign_in(@admin)
  end

  test 'create and modify user' do
    click_on 'Conferences'
    assert_content page, @conference.acronym
    click_on 'Show'
    click_on 'People'
    click_on 'All people'
    assert_content page, @person.email
    within("tr", text: @person.email) do
      click_on('User')
    end
    assert_content page, "Create account for #{@person.public_name}"
    fill_in 'Email', with: @person.email
    fill_in 'Password', with: 'frab123'
    fill_in 'Password confirmation', with: 'frab123'
    click_on 'Create User'
    assert_content page, @person.public_name
    assert_content page, "Edit Account: #{@person.public_name}"
    choose('crew')
    click_on 'Update User'
    assert_content page, "Edit Account: #{@person.public_name}"
    assert_content page, 'Admin'
  end

  def sign_in(user)
    visit root_path
    click_on 'Log-in'
    fill_in 'Email', with: user.email
    fill_in 'Password', with: 'frab123'
    click_on 'Log in'
  end
end
