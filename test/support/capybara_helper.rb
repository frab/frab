module CapybaraHelper
  def sign_in(email, password)
    visit root_path
    click_on 'Log-in'
    fill_in 'Email', match: :first, with: email
    fill_in 'Password', with: password
    click_on 'Log in'
  end

  def sign_in_user(user)
    sign_in(user.email, 'frab123')
  end

  def sign_out
    click_on 'Account'
    click_on 'Logout'
  end
end
