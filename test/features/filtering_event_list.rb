require 'test_helper'

class EditingEventRatingTest < FeatureTest
  setup do
    @conference = create(:three_day_conference_with_events)
    @coordinator = create(:conference_coordinator, conference: @conference)
    @user = @coordinator.user

    @event1 = @conference.events[0]
    @event2 = @conference.events[1]
    @event3 = @conference.events[2]
    @event1.update_attributes(event_type: 'film')
    @event2.update_attributes(event_type: 'lecture')
    @event3.update_attributes(event_type: 'dance')

    EventRating.create(event: @event2, person: @coordinator.person, rating: 3, comment: "comment1")
  end

  it 'can filter event list by clicking a term', js: true do
    sign_in_user(@user)
    visit "/#{@conference.acronym}/events/"
    
    click_on 'Film'
    assert_content page, '╳ Event type : Film'
    assert_content page, @event1.title
    refute_content page, @event2.title
    refute_content page, @event3.title
  end

  it 'can filter event list by clicking a number', js: true do
    sign_in_user(@user)
    visit "/#{@conference.acronym}/events/ratings"
    find('a', text: /^1$/).click
    assert_content page, '╳ Event ratings count ≥ 1'
    refute_content page, @event1.title
    assert_content page, @event2.title
    refute_content page, @event3.title
  end

  it 'can filter event list by using the multi-filter', js: true do
    sign_in_user(@user)
    visit "/#{@conference.acronym}/events/"
    
    # click the filter icon next to table header "Type"
    find('th', text: 'Type').find('.show_events_modal').trigger('click')
    assert_content page, 'Select filter for'
    
    check 'Film'
    check 'dance'
    
    find('#apply_filter_btn')
    # TODO - this fails because phantomjs does not support URL.searchParams.set
    # click_on 'Apply filter'
    visit "/#{@conference.acronym}/events?event_type=film|dance"
    
    assert_content page, '╳ Event type : multiple'

    assert_content page, @event1.title
    refute_content page, @event2.title
    assert_content page, @event3.title
  end

  it 'can filter event list by using numeric modal', js: true do
    sign_in_user(@user)
    visit "/#{@conference.acronym}/events/ratings"
    
    # click the filter icon next to table header "Event ratings count"
    find('th', text: 'Event ratings count').find('.show_events_modal').trigger('click')
    assert_content page, 'Select filter for Event ratings count:'
    
    page.find_all(class: "radio", text: "at most").select
    find("input#filter_form_num").send_keys('0.5')

    find('#apply_filter_btn')
    # TODO - this fails because phantomjs does not support URL.searchParams.set
    # click_on 'Apply filter'
    visit "/#{@conference.acronym}/events/ratings?event_ratings_count=%E2%89%A40.5"

    assert_content page, '╳ Event ratings count ≤ 0.5'

    assert_content page, @event1.title
    refute_content page, @event2.title
    assert_content page, @event3.title
  end
end
