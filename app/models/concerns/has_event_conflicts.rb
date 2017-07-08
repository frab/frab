require 'active_support/concern'

module HasEventConflicts
  extend ActiveSupport::Concern

  included do
    has_many :conflicts_as_conflicting, class_name: 'Conflict', foreign_key: 'conflicting_event_id', dependent: :destroy
    has_many :conflicts, dependent: :destroy
    after_save :update_conflicts
    scope :no_conflicts, -> { includes(:conflicts).where("conflicts.event_id": nil) }
  end

  def update_conflicts
    conflicts.delete_all
    conflicts_as_conflicting.delete_all
    if accepted? and room and start_time and time_slots
      update_room_conflicts
      update_people_conflicts
    end
    conflicts
  end

  def conflict_level
    return 'fatal' if conflicts.any? { |c| c.severity == 'fatal' }
    return 'warning' if conflicts.any? { |c| c.severity == 'warning' }
    nil
  end

  def update_attributes_and_return_affected_ids(attributes)
    affected_event_ids = conflicts.map(&:conflicting_event_id)
    update_attributes(attributes)
    reload
    affected_event_ids += conflicts.map(&:conflicting_event_id)
    affected_event_ids.delete(nil)
    affected_event_ids << id
    affected_event_ids.uniq
  end

  def update_speaker_conflicts(event_person)
    events = event_person.person.public_and_accepted_events_as_speaker_in(conference)
    events.to_a.combination(2).each do |a, b|
      if a.overlap?(b)
        Conflict.create(event: a, conflicting_event: b, person: event_person.person, conflict_type: 'person_already_speaking', severity: 'warning')
        Conflict.create(event: b, conflicting_event: a, person: event_person.person, conflict_type: 'person_already_speaking', severity: 'warning')
      end
    end
  end

  private

  # check if room has been assigned multiple times for the same slot
  def update_room_conflicts
    conflicting_event_candidates =
      self.class.accepted
        .where(room_id: room.id)
        .where(self.class.arel_table[:start_time].gteq(start_time.beginning_of_day))
        .where(self.class.arel_table[:start_time].lteq(start_time.end_of_day))
        .where(self.class.arel_table[:id].not_eq(id))

    conflicting_event_candidates.each do |conflicting_event|
      if overlap?(conflicting_event)
        Conflict.create(event: self, conflicting_event: conflicting_event, conflict_type: 'events_overlap', severity: 'fatal')
        Conflict.create(event: conflicting_event, conflicting_event: self, conflict_type: 'events_overlap', severity: 'fatal')
      end
    end
  end

  # check wether person has availability and is available at scheduled time
  def update_people_conflicts
    event_people.presenter.group(:person_id, :id).each do |event_person|
      next if conflict_person_has_no_availabilities(event_person)
      conflict_person_not_available(event_person)
      update_speaker_conflicts(event_person)
    end
  end

  def conflict_person_has_no_availabilities(event_person)
    return if event_person.person.availabilities.present?
    Conflict.create(event: self, person: event_person.person, conflict_type: 'person_has_no_availability', severity: 'warning')
  end

  def conflict_person_not_available(event_person)
    return if event_person.available_between?(start_time, end_time)
    Conflict.create(event: self, person: event_person.person, conflict_type: 'person_unavailable', severity: 'warning')
  end
end
