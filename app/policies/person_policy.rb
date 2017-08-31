class PersonPolicy < ApplicationPolicy
  def manage?
    return true if user.is_admin?
    return true if user.any_crew?('orga', 'coordinator')
    false
  end

  alias attend? manage?
  alias new? manage?
  alias create? manage?
  alias edit? manage?
  alias update? manage?
  alias destroy? manage?

  # normally no policies for cfp view, but this is shared with admin view
  def edit_availability?
    return true if user.person == record
    manage?
  end

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
