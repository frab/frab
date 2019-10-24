require 'test_helper'

feature 'CanAccessHome' do
  scenario 'home page shows' do
    visit root_path
    page.must_have_content 'frab'
  end

  scenario 'home page shows when js is enabled', js: true do
    visit root_path
    page.must_have_content 'frab'
  end
end
