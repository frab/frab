module CapybaraHelper
  def sign_in(email, password)
    visit root_path
    click_on 'Log-in'
    fill_in 'Email', match: :first, with: email
    fill_in 'Password', with: password
    click_on 'Log in'
    assert_content page, "Signed in successfully"
  end

  def sign_in_user(user)
    sign_in(user.email, 'frab123')
  end

  def sign_out
    click_on 'Account'
    click_on 'Logout'
  end

  # Helper to skip flaky modal tests unless explicitly enabled
  def skip_modal_tests_unless_enabled(message = "Modal tests are flaky - set ENABLE_MODAL_TESTS=1 to run")
    skip message unless ENV['ENABLE_MODAL_TESTS'] == '1'
  end
end
