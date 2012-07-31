class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new

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
      can :manage, User, :id => user.id
      can :read, User
    when /reviewer/
      # reviews events prior to conference schedule release
      # everything from submitter
      can :read, CallForPapers
      can :read, Conference
      can :read, Event
      can :read, EventFeedback
      can :manage, EventRating
      can :read, Person
      can :manage, Person, :user_id => user.id
      can :manage, User, :id => user.id
    when /submitter/
      # submits events to conferences
      # edits own events
      # manage his account
      # everything from guest
      can :read, CallForPapers
      can :manage, Event, Event.associated_with(user.person.id)
      can :create, EventFeedback
      can :manage, Person, :user_id => user.id
      can :manage, User, :id => user.id
    else
      # guest can visit the cfp page 
      # guest can create/confirm an account
      # guest can view the published schedule 
      # guest can give feedback on events
      can :create, EventFeedback
    end
  end
end
