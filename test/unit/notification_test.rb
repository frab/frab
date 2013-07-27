require 'test_helper'

class NotificationTest < ActiveSupport::TestCase

  setup do
    @cfp = FactoryGirl.create(:call_for_papers)
    FactoryGirl.create(:notification, call_for_papers: @cfp, locale: "EN")
    FactoryGirl.create(:notification, call_for_papers: @cfp, locale: "DE")
    @cfp.reload
  end

  test "call for papers can have multiple notifications" do
    assert_equal @cfp.notifications.count, 2
  end

  test "cannot add same language twice" do
      notification = Notification.new(call_for_papers: @cfp, locale: "EN")
      notification.set_default_text "EN"
      assert !notification.valid?
  end

end
