class EventPolicy < ApplicationPolicy
  def show?
    user.is_admin? || user.is_crew_of?(record.conference) || (user.person && record.people.include?(user.person))
  end

  alias people? show?

  def edit?
    user.is_admin? || user.is_manager_of?(record.conference) || (user.person && record.people.include?(user.person))
  end

  alias create? edit?
  alias custom_notification? edit?
  alias destroy? edit?
  # alias edit_people? edit?
  def edit_people?
    edit? || (user.person && record.people.include?(user.person))
  end
  alias update? edit?
  alias update_state? edit?
  alias translations? edit?

  class Scope < Scope
    def resolve
      scope
    end
  end
end
