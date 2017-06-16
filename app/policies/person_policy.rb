class PersonPolicy < ApplicationPolicy
  def manage?
    return true if user.is_admin?
    (user.is_admin? || user.any_crew?('orga', 'coordinator'))
  end

  alias attend? manage?
  alias new? manage?
  alias create? manage?
  alias edit? manage?
  alias update? manage?
  alias destroy? manage?

  def show?
    return true if user.person == record || user.is_admin?
    return true if user.any_crew?('orga', 'coordinator')
    return true if record.submitter_of?(user.reviews_conferences)
    false
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
