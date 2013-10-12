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
    # However :manage matches all rules, if a custom rule exists and shall not be matched
    # by :manage, then :crud can be used instead of :manage.
    #
    # TODO get rid of 'class' syntax
    #   Not sure if subject class can be arbirtrary: it can! :read, :logs
    # TODO Instead: If it ain't CRUD don't crud!
    #  Person, User, Event, EventRating
    #  but manage is a wildcard...

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
      can [:access, :make], :event_feedback

      can :crud, Person, :id => @user.person.id
      cannot :control, Person

      can :crud, User, :id => @user.id
      cannot :control, User
      cannot :assign_roles, User
      cannot :assign_user_roles, User

    else
      # guest can visit the cfp page 
      # guest can create/confirm an account
      # guest can view the published schedule 
      # guest can give feedback on events
      can [:access, :make], :event_feedback
      cannot :control, User
      cannot :assign_roles, User
      cannot :assign_user_roles, User
    end
  end

  def setup_crew_user_abilities
    crew_role = get_conference_role
    case crew_role
    when /orga/
      can :control, CallForPapers
      can :control, Conference
      can :manage, Event, :conference_id => @conference.id
      can [:access, :make, :control], :event_feedback
      can :manage, EventRating
      can :manage, Person
      #can :control, Person # dupe
      can :control, User
      can [:read, :create, :update], User do |user|
        (user.is_submitter? and user.person.involved_in @conference) or user.is_crew_of?(@conference)
      end
      can :assign_user_roles, User
      cannot :assign_roles, User

    when /coordinator/
      # coordinates speakers and their events
      # everything from reviewer
      can :control, CallForPapers
      cannot :destroy, CallForPapers
      can :read, Conference
      can :manage, Event, :conference_id => @conference.id
      can :access, :event_feedback
      can :manage, EventRating
      can :manage, Person
      #can :control, Person # dupe

    when /reviewer/
      # reviews events prior to conference schedule release
      # everything from submitter
      can :read, CallForPapers
      can :read, Conference
      can :read, Event, conference_id: @conference.id
      can :submit, Event
      can :access, :event_feedback
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
