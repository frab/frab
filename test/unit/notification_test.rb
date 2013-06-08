require 'test_helper'

class NotificationTest < ActiveSupport::TestCase
  test "cannot add same language twice" do
    notifications = FactoryGirl.create(:notification)
    notifications = FactoryGirl.create(:notification)
  end
end
