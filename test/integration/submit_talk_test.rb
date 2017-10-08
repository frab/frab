require 'test_helper'

class SubmitTalkTest < ActionDispatch::IntegrationTest
  setup do
    @conference = create(:three_day_conference, title: 'present conference')
    create(:call_for_participation, conference: @conference)
    @user = create(:user)
  end

  test 'can submit talk' do
    get "/#{@conference.acronym}/cfp"
    sign_in(@user)

    patch "/#{@conference.acronym}/cfp/person", params: {"person"=>{"first_name"=>"A", "last_name"=>"Submitter", "public_name"=>"Name", "gender"=>"male", "email"=>"test@example.org", "email_public"=>"1", "abstract"=>"", "description"=>""}, "commit"=>"Update profile", "locale"=>"en", "conference_acronym"=>"presentconf"}

    post "/#{@conference.acronym}/cfp/events", params: {"event"=>{"title"=>"My talk", "subtitle"=>"", "event_type"=>"", "track_id"=>"", "time_slots"=>"3", "language"=>"en", "abstract"=>"About myself", "description"=>"", "submission_note"=>""}, "commit"=>"Create event", "locale"=>"en", "conference_acronym"=>"presentconf"}

    assert_equal 'A', @user.person.first_name
    assert_equal 1, @user.person.events.count
  end
end
