class EventRatingPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      return scope.all if user.is_admin?

      conference = scope.first&.conference
      if conference && user.is_manager_of?(conference)
        scope.all
      else
        scope.where(person_id: user.person.id)
      end
    end
  end
end
