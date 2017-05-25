require 'test_helper'

class CanLoginTest < Capybara::Rails::TestCase
  setup do
    @admin = create(:user, role: 'admin', password: 'frab123')
  end

  test 'sanity' do
    visit root_path
    click_on 'Log-in'
    fill_in 'Email', with: @admin.email
    fill_in 'Password', with: 'frab123'
    click_on 'Log in'
    assert_content page, 'Create new conference'
  end
end
