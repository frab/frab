class EventPolicy < ApplicationPolicy
  def show?
    user.is_admin? || user.is_crew_of?(record.conference)
  end

  alias people? show?

  def edit?
    user.is_admin? || user.is_manager_of?(record.conference)
  end

  alias create? edit?
  alias custom_notification? edit?
  alias destroy? edit?
  alias edit_people? edit?
  alias toggle_locked? edit?
  alias update? edit?
  alias update_state? edit?
  alias translations? edit?

  class Scope < Scope
    def resolve
      scope
    end
  end
end
