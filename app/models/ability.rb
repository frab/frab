# = Attention: Conditional Abilities
#
#   can :manage, EventRating, person_id: user.person.id
#
# This means a user passes every check for EventRating the class, but may
# only :manage @event_rating if it belongs to her.
# see: https://github.com/ryanb/cancan/wiki/Checking-Abilities
#
#   "Important: If a block or hash of conditions exist they will be ignored
#   when checking on a class, and it will return true."
#
# As a solution, instead of manage, crud is used for the hash condition.
#
# Example:
#  can :crud, Conference, id: 1
#  can? :manage, Conference          => false
#  can? :administrate, Conference    => false
#  can? :create, Conference          => true
#  can? :read, @conference           => true
#
# = Wildcard Matching with :manage
#
# :manage matches all rules, if a custom rule exists and shall not be matched
# by :manage, then :crud can be used instead of :manage.
#
class Ability
  include CanCan::Ability

  def initialize(user, conference)
    @user = user || User.new
    @conference = conference

    alias_action :create, :read, :update, :destroy, to: :crud

    # nested conference resources alias, these actions only show the form, the
    # actual update is handled by :update
    alias_action :edit_rooms, :edit_tracks, :edit_days, :edit_schedule, to: :read_nested_conference

    setup_user_abilities

    if user.is_crew?
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

      can :crud, Person, id: @user.person.id

      can :crud, User, id: @user.id

    end

    # when /guest/
    #   can visit the cfp page
    #   can create/confirm an account
    #   can view the published schedule
    #   can give feedback on events
  end

  def setup_crew_user_abilities
    crew_role = get_conference_role
    case crew_role
    when /orga/
      can :manage, CallForParticipation

      can [:read, :read_nested_conference, :edit_ticket_server, :update], Conference, id: @conference.id

      can :crud, Event, conference_id: @conference.id
      can :manage, EventRating
      can :manage, Person

      can :administrate, User
      can :crud, User do |user|
        not user.is_admin?
      end
      can :assign_user_roles, User
      can :assign_user_roles, Conference do |conference|
        @user.conference_users.any? { |cu|
          cu.conference == conference and cu.role == 'orga'
        }
      end
      cannot :assign_roles, User

    when /coordinator/
      # coordinates speakers and their events
      # everything from reviewer
      can [:create, :read, :update], CallForParticipation
      can [:read, :read_nested_conference], Conference

      can :crud, Event, conference_id: @conference.id
      can :manage, EventRating
      can :manage, Person

    when /reviewer/
      # reviews events prior to conference schedule release
      # everything from submitter
      # edit own event rating
      can :read, CallForParticipation
      can [:read, :read_nested_conference], Conference

      can :read, Event, conference_id: @conference.id
      can :crud, EventRating, person_id: @user.person.id
      can :read, EventRating
      can :read, Person

    end

    can :access, :event_feedback
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
