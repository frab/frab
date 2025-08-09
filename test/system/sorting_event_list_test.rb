require 'application_system_test_case'

class SortingEventListTest < ApplicationSystemTestCase
  setup do
    @conference = create(:three_day_conference_with_review_metrics_and_events_and_reviews)
    @conference.events.each do |event|
      event.update(track: create(:track, conference: @conference))
    end

    @coordinator = create(:conference_coordinator, conference: @conference)

    # Upload a file to enable "Attachments" view
    upload = Rack::Test::UploadedFile.new(Rails.root.join('test', 'fixtures', 'textfile.txt'), 'text/plain')
    @conference.events.first.update( event_attachments_attributes: { 'xx' => { 'title' => 'proposal', 'attachment' => upload } })
  end

  test 'can sort' do
    sign_in_user(@coordinator.user)
    visit "/#{@conference.acronym}/events/"
    find_all(:css, 'ul.nav.nav-tabs li').map(&:text).each do |tabname|
      click_on tabname
      find("a.nav-link", class: "active", text: tabname)

      find_all(:css, "th a.sort_link").map(&:text).each do |column|
        click_on column
        assert_content page, "#{column} ▲"

        click_on "#{column}", match: :prefer_exact
        assert_content page, "#{column} ▼"
      end
    end
  end
end
