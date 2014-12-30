require 'test_helper'

class NotificationTest < ActiveSupport::TestCase

  setup do
    @cfp = FactoryGirl.create(:call_for_papers)
    FactoryGirl.create(:notification, call_for_papers: @cfp, locale: "en")
    FactoryGirl.create(:notification, call_for_papers: @cfp, locale: "de")
    @cfp.reload
  end

  test "call for papers can have multiple notifications" do
    assert_equal @cfp.notifications.count, 2
  end

  test "cannot add same language twice" do
      notification = Notification.new(call_for_papers: @cfp, locale: "en")
      notification.set_default_text "en"
      assert !notification.valid?
  end

end
