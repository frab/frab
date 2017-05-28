class EventPolicy < ApplicationPolicy
  def show?
    user.is_admin? || user.is_crew_of?(record.conference)
  end

  def people?
    show?
  end

  def edit?
    user.is_admin? || user.is_manager_of?(record.conference)
  end

  def edit_people?
    edit?
  end

  def create?
    edit?
  end

  def update?
    edit?
  end

  def update_state?
    edit?
  end

  def custom_notification?
    edit?
  end

  def destroy?
    edit?
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
