module CapybaraHelper
  def sign_in(email, password)
    visit root_path
    click_on 'Log-in'
    fill_in 'Email', with: email
    fill_in 'Password', with: password
    click_on 'Log in'
  end

  def visit_conference_settings
    click_on 'Conferences'
    click_on 'Show'
    find('ul.nav:eq(2)').click_link('Settings')
  end
end
