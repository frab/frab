require 'application_system_test_case'

class CanAccessHomeTest < ApplicationSystemTestCase
  test 'home page shows' do
    visit root_path
    assert_content page, 'frab'
  end

  test 'home page shows when js is enabled' do
    visit root_path
    assert_content page, 'frab'
  end
end
