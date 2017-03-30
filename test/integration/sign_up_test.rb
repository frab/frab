require 'test_helper'

class SignUpTest < ActionDispatch::IntegrationTest
  setup do
    @conference = create(:three_day_conference, title: 'present conference')
    create(:call_for_participation, conference: @conference)
  end

  test 'can sign up for cfp and get redirected to cfp page' do
    get '/'
    assert_includes @response.body, '<title>frab - home'
    assert_includes @response.body, @conference.title
    get "/#{@conference.acronym}/cfp"
    assert_includes @response.body, "<title>#{@conference.title}"
    assert_includes @response.body, "#{@conference.title}\n- Call for Participation"
  end
end
