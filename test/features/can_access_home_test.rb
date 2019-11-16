require 'test_helper'

feature 'CanAccessHome' do
  scenario 'home page shows' do
    visit root_path
    assert_content page, 'frab'
  end

  scenario 'home page shows when js is enabled', js: true do
    visit root_path
    assert_content page, 'frab'
  end
end
