require 'test_helper'

class AbilitiesTest < ActiveSupport::TestCase
  setup do
    # Event
    @event = FactoryGirl.create :event

    # Conference
    @conference = @event.conference

    # CallForParticipation
    @cfp = FactoryGirl.create :call_for_participation, :conference => @conference

    # Person
    @person = FactoryGirl.create :person

    # EventRating
    @rating = FactoryGirl.create :event_rating, :event => @event, :rating => 4.0

    # User
    @other_user = FactoryGirl.create :user

    @orga_user = FactoryGirl.create(:conference_orga, conference: @conference).user
    @coordinator_user = FactoryGirl.create(:conference_coordinator, conference: @conference).user
    @reviewer_user = FactoryGirl.create(:conference_reviewer, conference: @conference).user

    @submitter_user = FactoryGirl.create :user
    @conference_event = FactoryGirl.create :event, conference: @conference
    FactoryGirl.create :event_person, person: @submitter_user.person, event: @conference_event

    @guest_user = FactoryGirl.create :user
    @guest_user.role = nil
  end

  test "orga has full access on everything" do
    ability = Ability.new @orga_user, @conference

    # full access on everything
    assert ability.can? :manage, CallForParticipation
    assert ability.can? :manage, @cfp
    assert ability.cannot? :manage, Conference
    assert ability.can? :read, @conference
    assert ability.can? :update, @conference
    assert ability.can? :crud, Event
    assert ability.can? :crud, @event
    assert ability.can? :access, :event_feedback
    assert ability.can? :manage, EventRating
    assert ability.can? :crud, @rating
    assert ability.can? :administrate, Person
    assert ability.can? :manage, Person
    assert ability.can? :manage, @person
  end

  test "orga has valid access on users" do
    ability = Ability.new @orga_user, @conference

    assert ability.can? :create, @submitter_user
    assert ability.can? :read, @submitter_user
    assert ability.can? :update, @submitter_user

    assert ability.can? :create, @reviewer_user
    assert ability.can? :read, @reviewer_user
    assert ability.can? :update, @reviewer_user

    assert ability.cannot? [:create, :read, :update], @other_user

    assert ability.can? :administrate, User
    assert ability.can? :assign_user_roles, User
    assert ability.cannot? :assign_roles, User
  end

  test "coordinator has full access on events, ratings and persons" do
    ability = Ability.new @coordinator_user, @conference
    assert ability.can? :crud, Event
    assert ability.can? :crud, @event
    assert ability.can? :manage, EventRating
    assert ability.can? :crud, @rating
    assert ability.can? :administrate, Person
    assert ability.can? :manage, Person
    assert ability.can? :manage, @person
  end

  test "coordinator may manage call for papers, but not destroy them" do
    ability = Ability.new @coordinator_user, @conference
    assert ability.can? :create, CallForParticipation
    assert ability.can? :read, CallForParticipation
    assert ability.can? :update, CallForParticipation
    assert ability.can? :create, @cfp
    assert ability.can? :read, @cfp
    assert ability.can? :update, @cfp
    assert ability.cannot? :destroy, CallForParticipation
    assert ability.cannot? :destroy, @cfp
  end

  test "coordinator can only read conferences" do
    ability = Ability.new @coordinator_user, @conference
    assert ability.can? :read, Conference
    assert ability.can? :read, @conference
    assert ability.cannot? :manage, @conference
    assert ability.cannot? :manage, Conference
  end

  test "coordinator can only read feedback" do
    ability = Ability.new @coordinator_user, @conference
    assert ability.can? :access, :event_feedback
    assert ability.cannot? :manage, :event_feedback
  end

  test "coordinator can read all users, but only manage self" do
    ability = Ability.new @coordinator_user, @conference
    assert ability.can? :crud, @coordinator_user
    assert ability.cannot? :update, @other_user
    assert ability.cannot? :administrate, User
  end

  test "coordinator cannot assign roles to users" do
    ability = Ability.new @coordinator_user, @conference
    assert ability.cannot? :assign_roles, User
    assert ability.cannot? :assign_roles, @other_user
    assert ability.cannot? :assign_roles, @coordinator_user
  end

  test "reviewer can only read conferences" do
    ability = Ability.new @reviewer_user, @conference
    assert ability.can? :read, Conference
    assert ability.can? :read, @conference
    assert ability.cannot? :manage, Conference
    assert ability.cannot? :manage, @conference
  end

  test "reviewer can only read call for papers" do
    ability = Ability.new @reviewer_user, @conference
    assert ability.can? :read, CallForParticipation
    assert ability.can? :read, @cfp
    assert ability.cannot? :manage, CallForParticipation
    assert ability.cannot? :manage, @cfp
  end

  test "reviewer can only read event feedback" do
    ability = Ability.new @reviewer_user, @conference
    assert ability.can? :access, :event_feedback
    assert ability.cannot? :manage, :event_feedback
  end

  test "reviewer can only read and submit events" do
    ability = Ability.new @reviewer_user, @conference
    assert ability.can? :read, Event
    assert ability.can? :read, @event
    assert ability.can? :submit, Event
    assert ability.cannot? :crud, Event
    assert ability.cannot? :crud, @event
  end

  test "reviewer can read all event ratings, but only manage self" do
    my_rating = FactoryGirl.create :event_rating, person: @reviewer_user.person
    ability = Ability.new @reviewer_user, @conference
    assert ability.can? :create, my_rating
    assert ability.can? :crud, my_rating
    assert ability.can? :read, @rating
    assert ability.cannot? :destroy, @rating
    assert ability.cannot? :manage, EventRating
  end

  test "reviewer can read all persons, but only manage self" do
    ability = Ability.new @reviewer_user, @conference
    assert ability.cannot? :administrate, Person
    assert ability.cannot? :manage, Person
    assert ability.can? :read, Person
    assert ability.can? :crud, @reviewer_user.person
    assert ability.can? :read, @person
    assert ability.cannot? :update, @person
  end

  test "reviewer can only read and manage own user" do
    ability = Ability.new @reviewer_user, @conference
    assert ability.can? :crud, @reviewer_user
    assert ability.cannot? :read, @other_user
    assert ability.cannot? :administrate, User
  end

  test "reviewer cannot assign roles to users" do
    ability = Ability.new @reviewer_user, @conference
    assert ability.cannot? :assign_roles, User
    assert ability.cannot? :assign_roles, @other_user
    assert ability.cannot? :assign_roles, @reviewer_user
  end

  test "submitter has no access to conferences" do
    ability = Ability.new @submitter_user, @conference
    assert ability.cannot? :read, Conference
    assert ability.cannot? :read, @conference
    assert ability.cannot? :manage, Conference
    assert ability.cannot? :manage, @conference
  end

  test "submitter has no access to call for papers" do
    ability = Ability.new @submitter_user, @conference
    assert ability.cannot? :read, CallForParticipation
    assert ability.cannot? :read, @cfp
    assert ability.cannot? :destroy, CallForParticipation
    assert ability.cannot? :destroy, @cfp
  end

  test "submitter can only create event feedback" do
    ability = Ability.new @submitter_user, @conference
    assert ability.cannot? :access, :event_feedback
    assert ability.cannot? :manage, :event_feedback
  end

  test "submitter can only submit events" do
    ability = Ability.new @submitter_user, @conference
    assert ability.can? :submit, Event
    assert ability.cannot? :read, Event
    assert ability.cannot? :read, @event
    assert ability.cannot? :crud, Event
    assert ability.cannot? :crud, @event
  end

  test "submitter has no access to event ratings" do
    my_rating = FactoryGirl.create :event_rating, person: @submitter_user.person
    ability = Ability.new @submitter_user, @conference
    assert ability.cannot? :read, my_rating
    assert ability.cannot? :manage, my_rating
    assert ability.cannot? :read, EventRating
    assert ability.cannot? :read, @rating
    assert ability.cannot? :crud, @rating
    assert ability.cannot? :manage, EventRating
  end

  test "submitter can only manage own person" do
    ability = Ability.new @submitter_user, @conference
    assert ability.can? :crud, @submitter_user.person
    assert ability.cannot? :crud, @person
    assert ability.cannot? :read, @person
  end

  test "submitter can only read and manage own user" do
    ability = Ability.new @submitter_user, @conference
    assert ability.can? :crud, @submitter_user
    assert ability.cannot? :read, @other_user
    assert ability.cannot? :crud, @other_user
    assert ability.cannot? :administrate, User
  end

  test "submitter cannot assign roles to users" do
    ability = Ability.new @submitter_user, @conference
    assert ability.cannot? :assign_roles, User
    assert ability.cannot? :assign_roles, @other_user
    assert ability.cannot? :assign_roles, @submitter_user
  end

  test "guest has no access to conferences" do
    ability = Ability.new @guest_user, @conference
    assert ability.cannot? :read, Conference
    assert ability.cannot? :manage, Conference
    assert ability.cannot? :manage, @conference
  end

  test "guest has no access to call for papers" do
    ability = Ability.new @guest_user, @conference
    assert ability.cannot? :read, CallForParticipation
    assert ability.cannot? :read, @cfp
    assert ability.cannot? :destroy, CallForParticipation
    assert ability.cannot? :destroy, @cfp
  end

  test "guest can only create event feedback" do
    ability = Ability.new @guest_user, @conference
    assert ability.cannot? :access, :event_feedback
    assert ability.cannot? :manage, :event_feedback
  end

  test "guest has no access to events" do
    ability = Ability.new @guest_user, @conference
    assert ability.cannot? :submit, Event
    assert ability.cannot? :read, Event
    assert ability.cannot? :read, @event
    assert ability.cannot? :crud, Event
    assert ability.cannot? :crud, @event
  end

  test "guest has no access to event ratings" do
    my_rating = FactoryGirl.create :event_rating, person: @guest_user.person
    ability = Ability.new @guest_user, @conference
    assert ability.cannot? :read, my_rating
    assert ability.cannot? :manage, my_rating
    assert ability.cannot? :read, EventRating
    assert ability.cannot? :read, @rating
    assert ability.cannot? :crud, @rating
    assert ability.cannot? :manage, EventRating
  end

  test "guest has no access to person" do
    ability = Ability.new @guest_user, @conference
    assert ability.cannot? :administrate, Person
    assert ability.cannot? :update, @guest_user.person
    assert ability.cannot? :manage, Person
    assert ability.cannot? :update, @person
  end

  test "guest has no access to user" do
    ability = Ability.new @guest_user, @conference
    assert ability.cannot? :read, @guest_user
    assert ability.cannot? :crud, @other_user
    assert ability.cannot? :administrate, User
  end

  test "guest cannot assign roles to users" do
    ability = Ability.new @guest_user, @conference
    assert ability.cannot? :assign_roles, User
    assert ability.cannot? :assign_roles, @other_user
    assert ability.cannot? :assign_roles, @guest_user
  end
end
