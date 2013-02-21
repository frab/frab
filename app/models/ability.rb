class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new

    #
    # Attention
    #
    #   can :manage, EventRating, person_id: user.person.id
    #
    # This means a user can [:manage,:read] EventRating, but may 
    # only :manage @event_rating if it belongs to her.
    # Take a look how these abilities are used across controllers, before changing them.

    # Attention: User.role vs. EventPerson.role
    case user.role
    when /admin/
      can :manage, :all
    when /orga/
      can :manage, CallForPapers
      can :manage, Conference
      can :manage, Event
      can :manage, EventFeedback
      can :manage, EventRating
      can :manage, Person
      can :manage, TicketServer
      can :manage, User
      can :assign_roles, User
    when /coordinator/
      # coordinates speakers and their events
      # everything from reviewer
      can :manage, CallForPapers
      cannot :destroy, CallForPapers
      can :read, Conference
      can :manage, Event
      can :read, EventFeedback
      can :manage, EventRating
      can :manage, Person
      can :read, TicketServer
      can :manage, User, id: user.id
      can :read, User
      cannot :assign_roles, User
    when /reviewer/
      # reviews events prior to conference schedule release
      # everything from submitter
      can :read, CallForPapers
      can :read, Conference
      can :read, Event
      can :submit, Event
      can :read, EventFeedback
      can :manage, EventRating, person_id: user.person.id
      can :manage, Person, id: user.person.id
      can :read, Person
      can :manage, User, id: user.id
      cannot :assign_roles, User
    when /submitter/
      # submits events to conferences
      # edits own events
      # manage his account
      # everything from guest
      can :submit, Event
      can :create, EventFeedback
      can :manage, Person, id: user.person.id
      can :manage, User, id: user.id
      cannot :assign_roles, User
    else
      # guest can visit the cfp page 
      # guest can create/confirm an account
      # guest can view the published schedule 
      # guest can give feedback on events
      can :create, EventFeedback
      cannot :assign_roles, User
    end
  end
end
