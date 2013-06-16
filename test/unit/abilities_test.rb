require 'test_helper'

class AbilitiesTest < ActiveSupport::TestCase

  setup do
    # Event
    @event = FactoryGirl.create(:event)

    # Conference
    @conference = @event.conference

    # CallForParticipation
    @cfp = FactoryGirl.create(:call_for_participation, :conference => @conference)

    # Person
    @person = FactoryGirl.create(:person)

    # EventRating
    @rating = FactoryGirl.create(:event_rating, :event => @event, :rating => 4.0)

    # EventFeedback
    @feedback = FactoryGirl.create(:event_feedback, :event => @event, :rating => 4.0)

    # User
    @other_user = FactoryGirl.create(:user)

    @coordinator_user = FactoryGirl.create(:coordinator_user)
    @reviewer_user = FactoryGirl.create(:reviewer_user)
    @submitter_user = FactoryGirl.create(:user)
    @guest_user = FactoryGirl.create(:user)
    @guest_user.role = nil
  end

  test "orga has full access on everything" do
    user = FactoryGirl.create(:orga_user)
    ability = Ability.new(user)

    # full access on everything
    assert ability.can?(:manage, CallForParticipation)
    assert ability.can?(:manage, @cfp)
    assert ability.can?(:manage, Conference)
    assert ability.can?(:manage, @conference)
    assert ability.can?(:manage, Event)
    assert ability.can?(:manage, @event)
    assert ability.can?(:manage, EventFeedback)
    assert ability.can?(:manage, @feedback)
    assert ability.can?(:manage, EventRating)
    assert ability.can?(:manage, @rating)
    assert ability.can?(:control, Person)
    assert ability.can?(:manage, Person)
    assert ability.can?(:manage, @person)
    assert ability.can?(:manage, User)
    assert ability.can?(:manage, @other_user)
    assert ability.can?(:assign_roles, User)
    assert ability.can?(:assign_roles, user)
    assert ability.can?(:assign_roles, @other_user)
  end

  test "coordinator has full access on events, ratings and persons" do
    ability = Ability.new(@coordinator_user)
    assert ability.can?(:manage, Event)
    assert ability.can?(:manage, @event)
    assert ability.can?(:manage, EventRating)
    assert ability.can?(:manage, @rating)
    assert ability.can?(:control, Person)
    assert ability.can?(:manage, Person)
    assert ability.can?(:manage, @person)
  end

  test "coordinator may manage call for participation, but not destroy them" do
    ability = Ability.new(@coordinator_user)
    assert ability.can?(:manage, CallForParticipation)
    assert ability.can?(:manage, @cfp)
    assert ability.cannot?(:destroy, CallForParticipation)
    assert ability.cannot?(:destroy, @cfp)
  end

  test "coordinator can only read and show conferences" do
    ability = Ability.new(@coordinator_user)
    assert ability.can?(:read, Conference)
    assert ability.can?(:show, Conference)
    assert ability.can?(:show, @conference)
    assert ability.cannot?(:manage, @conference)
    assert ability.cannot?(:manage, Conference)
  end

  test "coordinator can only read feedback" do
    ability = Ability.new(@coordinator_user)
    assert ability.can?(:read, EventFeedback)
    assert ability.can?(:read, @feedback)
    assert ability.cannot?(:manage, EventFeedback)
    assert ability.cannot?(:manage, @feedback)
  end

  test "coordinator can read all users, but only manage self" do
    ability = Ability.new(@coordinator_user)
    assert ability.can?(:manage, @coordinator_user)
    assert ability.cannot?(:manage, @other_user)
  end

  test "coordinator cannot assign roles to users" do
    ability = Ability.new(@coordinator_user)
    assert ability.cannot?(:assign_roles, User)
    assert ability.cannot?(:assign_roles, @other_user)
    assert ability.cannot?(:assign_roles, @coordinator_user)
  end

  test "reviewer can only read conferences" do
    ability = Ability.new(@reviewer_user)
    assert ability.can?(:read, Conference)
    assert ability.can?(:show, Conference)
    assert ability.can?(:show, @conference)
    assert ability.cannot?(:manage, Conference)
    assert ability.cannot?(:manage, @conference)
  end

  test "reviewer can only read call for participation" do
    ability = Ability.new(@reviewer_user)
    assert ability.can?(:read, CallForParticipation)
    assert ability.can?(:read, @cfp)
    assert ability.cannot?(:manage, CallForParticipation)
    assert ability.cannot?(:manage, @cfp)
  end

  test "reviewer can only read event feedback" do
    ability = Ability.new(@reviewer_user)
    assert ability.can?(:read, EventFeedback)
    assert ability.can?(:read, @feedback)
    assert ability.cannot?(:manage, EventFeedback)
    assert ability.cannot?(:manage, @feedback)
  end

  test "reviewer can only read and submit events" do
    ability = Ability.new(@reviewer_user)
    assert ability.can?(:read, Event)
    assert ability.can?(:read, @event)
    assert ability.can?(:submit, Event)
    assert ability.cannot?(:manage, Event)
    assert ability.cannot?(:manage, @event)
  end

  test "reviewer without person can still only read and submit events" do
    user= FactoryGirl.create(:reviewer_user)
    user.person = nil
    ability = Ability.new(user)
    assert ability.can?(:read, Event)
    assert ability.can?(:read, @event)
    assert ability.can?(:submit, Event)
    assert ability.cannot?(:manage, Event)
    assert ability.cannot?(:manage, @event)
  end

  test "reviewer can read all event ratings, but only manage self" do
    my_rating = FactoryGirl.create(:event_rating, person: @reviewer_user.person)
    ability = Ability.new(@reviewer_user)
    assert ability.can?(:create, my_rating)
    assert ability.can?(:manage, my_rating)
    assert ability.can?(:read, @rating)
    assert ability.cannot?(:manage, @rating)
  end

  test "reviewer can read all persons, but only manage self" do
    ability = Ability.new(@reviewer_user)
    assert ability.cannot?(:control, Person)
    assert ability.can?(:manage, Person)
    assert ability.can?(:manage, @reviewer_user.person)
    assert ability.can?(:read, @person)
    assert ability.cannot?(:manage, @person)
  end

  test "reviewer can only read and manage own user" do
    ability = Ability.new(@reviewer_user)
    assert ability.can?(:read, @reviewer_user)
    assert ability.can?(:manage, @reviewer_user)
    assert ability.cannot?(:read, @other_user)
    assert ability.cannot?(:manage, @other_user)
  end

  test "reviewer cannot assign roles to users" do
    ability = Ability.new(@reviewer_user)
    assert ability.cannot?(:assign_roles, User)
    assert ability.cannot?(:assign_roles, @other_user)
    assert ability.cannot?(:assign_roles, @reviewer_user)
  end

  test "submitter has no access to conferences" do
    ability = Ability.new(@submitter_user)
    assert ability.cannot?(:read, Conference)
    assert ability.cannot?(:show, Conference)
    assert ability.cannot?(:show, @conference)
    assert ability.cannot?(:manage, Conference)
    assert ability.cannot?(:manage, @conference)
  end

  test "submitter has no access to call for participation" do
    ability = Ability.new(@submitter_user)
    assert ability.cannot?(:read, CallForParticipation)
    assert ability.cannot?(:read, @cfp)
    assert ability.cannot?(:destroy, CallForParticipation)
    assert ability.cannot?(:destroy, @cfp)
  end

  test "submitter can only create event feedback" do
    ability = Ability.new(@submitter_user)
    assert ability.can?(:create, EventFeedback)
    assert ability.cannot?(:read, @feedback)
    assert ability.cannot?(:read, @feedback)
    assert ability.cannot?(:manage, EventFeedback)
    assert ability.cannot?(:manage, @feedback)
  end

  test "submitter can only submit events" do
    ability = Ability.new(@submitter_user)
    assert ability.can?(:submit, Event)
    assert ability.cannot?(:read, Event)
    assert ability.cannot?(:read, @event)
    assert ability.cannot?(:manage, Event)
    assert ability.cannot?(:manage, @event)
  end

  test "submitter has no access to event ratings" do
    my_rating = FactoryGirl.create(:event_rating, person: @submitter_user.person)
    ability = Ability.new(@submitter_user)
    assert ability.cannot?(:read, my_rating)
    assert ability.cannot?(:manage, my_rating)
    assert ability.cannot?(:read, EventRating)
    assert ability.cannot?(:read, @rating)
    assert ability.cannot?(:manage, @rating)
    assert ability.cannot?(:manage, EventRating)
  end

  test "submitter can only manage own person" do
    ability = Ability.new(@submitter_user)
    assert ability.can?(:manage, @submitter_user.person)
    assert ability.cannot?(:manage, @person)
    assert ability.cannot?(:read, @person)
  end

  test "submitter can only read and manage own user" do
    ability = Ability.new(@submitter_user)
    assert ability.can?(:read, @submitter_user)
    assert ability.can?(:manage, @submitter_user)
    assert ability.cannot?(:read, @other_user)
    assert ability.cannot?(:manage, @other_user)
  end

  test "submitter cannot assign roles to users" do
    ability = Ability.new(@submitter_user)
    assert ability.cannot?(:assign_roles, User)
    assert ability.cannot?(:assign_roles, @other_user)
    assert ability.cannot?(:assign_roles, @submitter_user)
  end

  test "guest has no access to conferences" do
    ability = Ability.new(@guest_user)
    assert ability.cannot?(:read, Conference)
    assert ability.cannot?(:show, Conference)
    assert ability.cannot?(:show, @conference)
    assert ability.cannot?(:manage, Conference)
    assert ability.cannot?(:manage, @conference)
  end

  test "guest has no access to call for participation" do
    ability = Ability.new(@guest_user)
    assert ability.cannot?(:read, CallForParticipation)
    assert ability.cannot?(:read, @cfp)
    assert ability.cannot?(:destroy, CallForParticipation)
    assert ability.cannot?(:destroy, @cfp)
  end

  test "guest can only create event feedback" do
    ability = Ability.new(@guest_user)
    assert ability.can?(:create, EventFeedback)
    assert ability.cannot?(:read, @feedback)
    assert ability.cannot?(:read, @feedback)
    assert ability.cannot?(:manage, EventFeedback)
    assert ability.cannot?(:manage, @feedback)
  end

  test "guest has no access to events" do
    ability = Ability.new(@guest_user)
    assert ability.cannot?(:submit, Event)
    assert ability.cannot?(:read, Event)
    assert ability.cannot?(:read, @event)
    assert ability.cannot?(:manage, Event)
    assert ability.cannot?(:manage, @event)
  end

  test "guest has no access to event ratings" do
    my_rating = FactoryGirl.create(:event_rating, person: @guest_user.person)
    ability = Ability.new(@guest_user)
    assert ability.cannot?(:read, my_rating)
    assert ability.cannot?(:manage, my_rating)
    assert ability.cannot?(:read, EventRating)
    assert ability.cannot?(:read, @rating)
    assert ability.cannot?(:manage, @rating)
    assert ability.cannot?(:manage, EventRating)
  end

  test "guest has no access to person" do
    ability = Ability.new(@guest_user)
    assert ability.cannot?(:control, Person)
    assert ability.cannot?(:manage, @guest_user.person)
    assert ability.cannot?(:manage, Person)
    assert ability.cannot?(:manage, @person)
  end

  test "guest has no access to user" do
    ability = Ability.new(@guest_user)
    assert ability.cannot?(:read, @guest_user)
    assert ability.cannot?(:manage, @guest_user)
    assert ability.cannot?(:manage, @other_user)
  end

  test "guest cannot assign roles to users" do
    ability = Ability.new(@guest_user)
    assert ability.cannot?(:assign_roles, User)
    assert ability.cannot?(:assign_roles, @other_user)
    assert ability.cannot?(:assign_roles, @guest_user)
  end
end
