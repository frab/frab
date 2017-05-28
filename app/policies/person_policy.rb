class PersonPolicy < ApplicationPolicy
  def manage?
    return true if user.is_admin?
    (user.is_admin? || user.any_crew?('orga', 'coordinator'))
  end

  def attend?
    manage?
  end

  def new?
    manage?
  end

  def create?
    manage?
  end

  def edit?
    manage?
  end

  def update?
    manage?
  end

  def destroy?
    manage?
  end

  def show?
    user.person == record || user.is_admin? || user.is_crew?
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
