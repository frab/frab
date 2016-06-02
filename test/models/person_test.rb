require 'test_helper'

class PersonTest < ActiveSupport::TestCase
  should validate_presence_of :public_name
  should validate_presence_of :email
  should have_many :availabilities
  should have_many :event_people
  should have_many :event_ratings
  should have_many :events
  should have_many :im_accounts
  should have_many :languages
  should have_many :links
  should have_many :phone_numbers
  should belong_to :user

  test '#full_name' do
    person = build(:person)
    assert_equal 'Fred Besen', person.full_name
    person = build(:person, first_name: 'Fred')
    assert_equal 'Fred Besen', person.full_name
    person = build(:person, first_name: 'Bred', last_name: 'Fesen')
    assert_equal 'Bred Fesen', person.full_name
  end

  test 'feedback average gets calculated correctly' do
    conference = create(:conference)
    event1 = create(:event, conference: conference)
    event2 = create(:event, conference: conference)
    event3 = create(:event, conference: conference)
    person = create(:person)
    create(:event_person, event: event1, person: person, event_role: :speaker)
    create(:event_person, event: event2, person: person, event_role: :speaker)
    create(:event_person, event: event3, person: person, event_role: :speaker)

    create(:event_feedback, event: event1, rating: 3.0)
    create(:event_feedback, event: event2, rating: 4.0)
    assert_equal 3.5, person.average_feedback_as_speaker

    # FIXME doesn't register another feedback for event2, thus
    # using a new one
    create(:event_feedback, event: event3, rating: 5.0)
    assert_equal 4.0, person.average_feedback_as_speaker
  end

  test 'expenses get calculated correctly' do
    conference = create(:conference)
    person = create(:person)
    e1 = create(:expense, value: 11.0, conference: conference, reimbursed: false)
    e2 = create(:expense, value: 22.0, conference: conference, reimbursed: true)
    e3 = create(:expense, value: 33.0, conference: conference, reimbursed: true)
    person.expenses = [e1, e2, e3]
    assert_equal person.sum_of_expenses(conference, false), e1.value
    assert_equal person.sum_of_expenses(conference, true), e2.value + e3.value
  end

  test 'persons merged correctly' do
    conference1 = create(:three_day_conference_with_events)
    conference2 = create(:three_day_conference_with_events)

    user1 = create(:crew_user)
    user2 = create(:crew_user)

    person1 = user1.person
    person2 = user2.person

    ConferenceUser.create! user_id: user1.id, conference_id: conference1.id, role: 'orga'
    ConferenceUser.create! user_id: user2.id, conference_id: conference1.id, role: 'reviewer'
    ConferenceUser.create! user_id: user2.id, conference_id: conference2.id, role: 'coordinator'

    assert_equal 2, User.count
    assert_equal 2, Person.count
    assert_equal 3, ConferenceUser.count

    event1 = conference1.events.first
    event2 = conference2.events.first
    create(:confirmed_event_person, event: event1, person: person1)
    create(:confirmed_event_person, event: event2, person: person2)

# Rails::logger.debug Availability.count

    person2.merge_with(person1)

    assert_equal 1, User.count
    assert_equal 1, Person.count
    assert_equal 2, ConferenceUser.count

    # check if the person2's user role for conference1 was properly up-merged to orga
    assert_equal 'orga', person2.user.conference_users.find_by(conference_id: conference1.id).role

  end

end
