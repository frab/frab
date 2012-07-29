class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new
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
      # TODO coordinators restricted to their conference
      can :manage, CallForPapers
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
      # TODO is the call_for_papers_id assigned to manually created users?
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
    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user permission to do.
    # If you pass :manage it will apply to every action. Other common actions here are
    # :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on. If you pass
    # :all it will apply to every resource. Otherwise pass a Ruby class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details: https://github.com/ryanb/cancan/wiki/Defining-Abilities
  end
end
