class UserPolicy < ApplicationPolicy
  # Orga may edit anybody in any conference except admins
  def destroy?
    return true if user.is_admin?
    return false if record.is_admin?
    return true if user.is_crew? && user == record
    return true if user.any_crew?('orga')
    false
  end

  alias show? destroy?
  alias edit? destroy?
  alias update? destroy?
  alias create? destroy?

  def create?
    user.is_admin? || user.any_crew?('orga', 'coordinator')
  end

  def index?
    user.is_admin?
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end

