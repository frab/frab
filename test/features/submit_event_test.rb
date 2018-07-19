require 'test_helper'

class SubmitEventTest < FeatureTest
  setup do
    @conference = create(:three_day_conference)
    create(:call_for_participation, conference: @conference)
  end

  def sign_up_steps
    click_on 'Sign Up', match: :first
    fill_in 'Email', with: @user.email
    fill_in 'Password', with: @user.password
    fill_in 'Password confirmation', with: @user.password
    click_on 'Sign up'
    assert_content page, 'A message with a confirmation link has been sent to your email address'

    User.last.confirm
  end

  def sign_in_steps
    click_on 'Log-in', match: :first
    fill_in 'Email', with: @user.email
    fill_in 'Password', with: @user.password
    click_on 'Log in'
    assert_content page, 'Signed in successfully'
  end

  test 'sign up and sign in new submitter' do
    @user = build(:user)
    visit root_path

    sign_up_steps
    sign_in_steps

    click_on 'Participate'
    assert_content page, 'Personal details'
  end

  test 'sign up and sign in new submitter to cfp' do
    @user = build(:user)
    visit "/#{@conference.acronym}/cfp"

    sign_up_steps
    sign_in_steps

    assert_content page, 'Personal details'
  end

  test 'submit an event' do
    @user = create(:user)

    sign_in(@user.email, @user.password)
    assert_content page, 'Signed in successfully'

    click_on 'Participate'
    click_on 'Submit a new event', match: :first

    fill_in 'title', with: 'fake-title', match: :first
    select '00:45', from: 'Time slots'
    click_on 'Create event'

    assert_content page, 'Events you already submitted'
    assert_content page, 'fake-title'

    click_on 'Edit availability', match: :first
    assert_content page, 'Edit availability'
    click_on 'Save availability'
    assert_content page, 'Thank you for specifying your availability'
  end
end

