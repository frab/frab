class UserConferenceContextPolicy < ApplicationPolicy
  def manage?
    user.is_admin? || user == record.user || orga_cannot_edit_admin
  end

  def destroy?
    user.is_admin? || orga_cannot_edit_admin
  end

  class Scope < Scope
    def resolve
      scope
    end
  end

  private

  def orga_cannot_edit_admin
    (user.is_orga_of?(record.conference) && !record.user.is_admin?)
  end
end
