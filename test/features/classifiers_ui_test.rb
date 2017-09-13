require 'test_helper'

class ClassifiersUiTest < FeatureTest
  setup do
    @conference = create(:three_day_conference_with_events)
    @admin = create(:admin_user)
    @event = @conference.events.first

    @classifier1 = create(:classifier, name: 'TestClassifier1', conference: @conference)
    @classifier2 = create(:classifier, name: 'TestClassifier2', conference: @conference)
  end

  it 'can toggle classifier', :js => true do
    sign_in_user(@admin)
    visit "/#{@conference.acronym}/events/#{@event.id}/edit"

    page.assert_no_selector '.event_event_classifiers_value'

    assert_content page, 'TestClassifier1'
    check '1', { :class => 'cocoon-checkbox' }
    check '2', { :class => 'cocoon-checkbox' }
    assert_selector('.event_event_classifiers_value', :count => 2)
    click_on('Update event')

    assert_equal @event.event_classifiers.count, 2, 'check two classifiers have been created in model'
    assert_equal @event.event_classifiers.first.value, 0, 'check default classifier value has been set'

    visit "/#{@conference.acronym}/events/#{@event.id}?format=json"
    assert_content page, 'TestClassifier2'
  end

  it 'can toggle off classifiers', :js => true do
    sign_in_user(@admin)
    visit "/#{@conference.acronym}/events/#{@event.id}/edit"
    assert_selector('.event_event_classifiers_value', :count => 0)
    check '1', { :class => 'cocoon-checkbox' }
    click_on('Update event')
    assert_equal @event.event_classifiers.count, 1

    visit "/#{@conference.acronym}/events/#{@event.id}/edit"
    assert_selector('.event_event_classifiers_value', :count => 1)
    uncheck '1', { :class => 'cocoon-checkbox' }
    click_on('Update event')
    assert_equal @event.event_classifiers.count, 0

    visit "/#{@conference.acronym}/events/#{@event.id}/edit"
    assert_selector('.event_event_classifiers_value', :count => 0)
  end

end
