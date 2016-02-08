require 'test_helper'

class DayTest < ActiveSupport::TestCase
  test 'day label matches format' do
    day = FactoryGirl.create(:day)

    assert_equal day.label, day.start_date.strftime('%Y-%m-%d')
  end

  test 'end date not possible before start date' do
    day = FactoryGirl.create(:day)
    assert_equal true, day.valid?

    day.start_date = day.start_date.since(3.days)
    assert_equal false, day.valid?

    day = FactoryGirl.create(:day)
    day.end_date = day.end_date.ago(2.days)
    assert_equal false, day.valid?
  end

  test 'day overlaps with other day' do
    conference = FactoryGirl.create(:three_day_conference)
    conference.days[1].start_date = conference.days[0].end_date.ago(2.hours)
    assert_equal false, conference.days[1].valid?
  end
end
