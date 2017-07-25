require 'test_helper'

class WithoutConferenceTest < ActionDispatch::IntegrationTest
  setup do
    @admin = create(:user, role: 'admin')
    @submitter = create(:user, role: 'submitter')
  end

  test 'can show home page' do
    get '/'
    assert_response :success
  end

  test 'submitter can login' do
    sign_in @submitter
    get '/'
    assert_response :success
  end

  test 'admin can login' do
    sign_in @admin
    get '/'
    assert_response :success
    get "/user/#{@admin.person.id}/edit"
    assert_response :success
    patch "/user/#{@admin.person.id}", params: { "user"=>{"email"=>"admin@example.org", "password"=>"test123", "password_confirmation"=>"test123", "role"=>"admin"} }
    assert_response :redirect
    get '/conferences/new'
    assert_response :success
  end
end
