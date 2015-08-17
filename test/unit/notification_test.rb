require 'test_helper'

class NotificationTest < ActiveSupport::TestCase

  setup do
    @cfp = FactoryGirl.create(:call_for_participation)
    FactoryGirl.create(:notification, conference: @cfp.conference, locale: "en")
    FactoryGirl.create(:notification, conference: @cfp.conference, locale: "de")
    @cfp.reload
  end

  test "call for papers can have multiple notifications" do
    assert_equal @cfp.conference.notifications.count, 2
  end

  test "cannot add same language twice" do
    notification = Notification.new(conference: @cfp.conference, locale: "en")
    notification.set_default_text "en"
    assert !notification.valid?
  end

end
