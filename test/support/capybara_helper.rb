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

  def visit_conference_settings_for(conference)
    click_on 'Conferences'
    within find('tr', text: conference.title) do
      click_on 'Show'
    end
    find('ul.nav:eq(2)').click_link('Settings')
  end
end
