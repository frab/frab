class ConferencePolicy < ApplicationPolicy
  # i.e.: event feedback, confernce index
  def index?
    user.is_admin? || user.is_crew?
  end

  def read?
    return false unless user
    user.is_admin? || user.is_crew_of?(record)
  end

  def orga?
    return false unless user
    return (user.is_admin? || user.any_crew?('orga')) if record.is_a?(Class)
    user.is_admin? || user.is_orga_of?(record)
  end

  alias create? orga?

  def manage?
    return (user.is_admin? || user.any_crew?('orga', 'coordinator')) if record.is_a?(Class)
    user.is_admin? || user.is_manager_of?(record)
  end

  def show?
    return false unless scope.where(id: record.id).exists?
    user.is_admin? || user.is_crew_of?(record)
  end

  def new?
    return false unless user
    user.is_admin? || user.any_crew?('orga')
  end

  def destroy?
    return false unless user
    user&.is_admin?
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
