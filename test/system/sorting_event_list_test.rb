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
    find_all(:css, 'ul.tabs li').map(&:text).each do |tabname|
      click_on tabname
      find("li", class: "active", text: tabname)

      find_all(:css, "th a.sort_link").map(&:text).each do |column|
        click_on column
        assert_content page, "#{column} ▲"

        col_index = find('table').find_all('th').index{|th| th.text=="#{column} ▲"}
        last_sorted_asc = find('table').find_all('tr').last.find_all('td')[col_index].text

        click_on "#{column}", match: :prefer_exact
        assert find('table').find_all('tr').first.find_all('th')[col_index].text == "#{column} ▼"

        first_sorted_desc = find('table').find_all('tr')[1].find_all('td')[col_index].text

        assert last_sorted_asc==first_sorted_desc, "Sorting '#{tabname}' page by '#{column}': '#{last_sorted_asc}' should equal '#{first_sorted_desc}'"
      end
    end
  end
end
