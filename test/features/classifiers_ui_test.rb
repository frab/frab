require 'test_helper'

class ClassifiersUiTest < FeatureTest
  setup do
    @conference = create(:three_day_conference_with_events)
    @admin = create(:admin_user)
    @event = @conference.events.first

    @classifier1 = create(:classifier, name: 'TestClassifier1', conference: @conference)
    @classifier2 = create(:classifier, name: 'TestClassifier2', conference: @conference)
  end

  it 'can toggle classifier', js: true do
    sign_in_user(@admin)
    visit "/#{@conference.acronym}/events/#{@event.id}/edit"

    assert_selector('.event_event_classifiers_value', count: 0)

    assert_content page, 'TestClassifier1'
    check 'classifier-checkbox-' + @classifier1.id.to_s
    check 'classifier-checkbox-' + @classifier2.id.to_s
    assert_selector('.event_event_classifiers_value', count: 2)
    click_on('Update event')

    assert_equal 2, @event.event_classifiers.count, 'check two classifiers have been created in model'
    assert_equal 0, @event.event_classifiers.first.value, 'check default classifier value has been set'

    visit "/#{@conference.acronym}/events/#{@event.id}?format=json"
    assert_content page, 'TestClassifier2'
  end

  it 'can toggle off classifiers', js: true do
    sign_in_user(@admin)
    visit "/#{@conference.acronym}/events/#{@event.id}/edit"
    assert_selector('.event_event_classifiers_value', count: 0)
    check 'classifier-checkbox-' + @classifier1.id.to_s
    click_on('Update event')
    assert_equal 1, @event.event_classifiers.count

    visit "/#{@conference.acronym}/events/#{@event.id}/edit"
    assert_selector('.event_event_classifiers_value', count: 1)
    uncheck 'classifier-checkbox-' + @classifier1.id.to_s
    click_on('Update event')
    assert_equal 0, @event.event_classifiers.count

    visit "/#{@conference.acronym}/events/#{@event.id}/edit"
    assert_selector('.event_event_classifiers_value', count: 0)
  end
end
