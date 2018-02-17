module CapybaraHelper
  def sign_in(email, password)
    visit root_path
    click_on 'Log-in'
    fill_in 'Email', with: email
    fill_in 'Password', with: password
    click_on 'Log in'
  end

  def sign_in_user(user)
    sign_in(user.email, 'frab123')
  end

  def visit_conference_settings(matcher = :first)
    click_on 'Conferences'
    click_on 'Show', match: matcher
    find('ul.nav:eq(2)').click_link('Settings')
  end
end
