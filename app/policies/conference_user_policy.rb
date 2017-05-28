class ConferenceUserPolicy < ApplicationPolicy
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
