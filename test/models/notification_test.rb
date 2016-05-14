require 'test_helper'

class NotificationTest < ActiveSupport::TestCase
  setup do
    @cfp = create(:call_for_participation)
    create(:notification, conference: @cfp.conference, locale: 'en')
    create(:notification, conference: @cfp.conference, locale: 'de')
    @cfp.reload
  end

  test 'call for papers can have multiple notifications' do
    assert_equal @cfp.conference.notifications.count, 2
  end

  test 'cannot add same language twice' do
    notification = Notification.new(conference: @cfp.conference, locale: 'en')
    notification.default_text = 'en'
    assert !notification.valid?
  end
end
