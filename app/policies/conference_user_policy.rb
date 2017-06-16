class ConferenceUserPolicy < ApplicationPolicy
  def destroy?
    return true if user.is_admin?
    conference_ids = user.organizes_conferences.map(&:conference_id)
    conference_ids.include?(record.conference_id)
  end

  alias edit? destroy?

  class Scope < Scope
    def resolve
      if user.is_admin?
        scope.all
      else
        conference_ids = user.manages_conferences.map(&:conference_id)
        scope.where(conference_id: conference_ids)
      end
    end
  end
end
