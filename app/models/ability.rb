class Ability
  include CanCan::Ability

  def initialize(user, conference)
    @user = user || User.new
    @conference = conference

    #
    # Attention
    #
    #   can :manage, EventRating, person_id: user.person.id
    #
    # This means a user can [:manage,:read] EventRating, but may 
    # only :manage @event_rating if it belongs to her.
    # Take a look how these abilities are used across controllers, before changing them.
    #
    # Whenever authorization against a class is needed, for which a limited instance rule 
    # exists, a new verb, like 'control' is introduced. This avoids the ambiguity of checking
    # classes versus instances.
    #

    #role = user.role
    setup_user_abilities

    if user.role == 'crew' 
      setup_crew_user_abilities
    end
  end

  protected

  def setup_user_abilities
    case @user.role
    when /admin/
      can :manage, :all

    when /submitter|crew/
      # submits events to conferences
      # edits own events
      # manage his account
      # everything from guest
      can :submit, Event
      can :create, EventFeedback

      can :manage, Person, :id => @user.person.id
      cannot :control, Person
      can :manage, User, :id => @user.id
      cannot :control, User
      cannot :assign_roles, User
      cannot :assign_user_roles, User

    else
      # guest can visit the cfp page 
      # guest can create/confirm an account
      # guest can view the published schedule 
      # guest can give feedback on events
      can :create, EventFeedback
      cannot :control, User
      cannot :assign_roles, User
      cannot :assign_user_roles, User
    end
  end

  def setup_crew_user_abilities
    crew_role = get_conference_role
    case crew_role
    when /orga/
      can :manage, CallForPapers
      can :manage, Conference
      can :manage, Event, :conference_id => @conference.id
      can :manage, EventFeedback
      can :manage, EventRating
      can :manage, Person
      can :control, Person
      can :control, User
      can :manage, User  # submitters and own crew
      can :assign_user_roles, User
      cannot :assign_roles, User

    when /coordinator/
      # coordinates speakers and their events
      # everything from reviewer
      can :manage, CallForPapers
      cannot :destroy, CallForPapers
      can :read, Conference
      can :manage, Event, :conference_id => @conference.id
      can :read, EventFeedback
      can :manage, EventRating
      can :manage, Person
      can :control, Person

    when /reviewer/
      # reviews events prior to conference schedule release
      # everything from submitter
      can :read, CallForPapers
      can :read, Conference
      can :read, Event, conference_id: @conference.id
      can :submit, Event
      can :read, EventFeedback
      can :manage, EventRating, :person_id => @user.person.id
      can :read, EventRating
      can :read, Person

    end
  end

  def get_conference_role
    if @conference.nil? and @user.conference_users.size > 0
      @conference = @user.conference_users.last.conference
    end
    unless @conference.nil?
      #raise "this user is missing a conference user" if @conference.nil?
      cu = ConferenceUser.where(user_id: @user, conference_id: @conference).first
      return cu.role unless cu.nil?
    end
    return
  end

end
