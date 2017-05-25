require 'test_helper'

feature 'CanAccessHome' do
  scenario 'the test is sound' do
    visit root_path
    page.must_have_content 'frab'
  end

  scenario 'the test is sound with js', js: true do
    visit root_path
    page.must_have_content 'frab'
  end
end
