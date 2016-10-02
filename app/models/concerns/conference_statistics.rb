require 'active_support/concern'

module ConferenceStatistics
  extend ActiveSupport::Concern

  def events_by_state
    [
      [[0, events.where(state: %w(new review)).count]],
      [[1, events.where(state: %w(accepting unconfirmed confirmed scheduled)).count]],
      [[2, events.where(state: %w(rejecting rejected)).count]],
      [[3, events.where(state: %w(withdrawn canceled)).count]]
    ]
  end

  def events_by_state_and_type(type)
    [
      [[0, events.where(state: %w(new review), event_type: type).count]],
      [[1, events.where(state: %w(accepting unconfirmed confirmed scheduled), event_type: type).count]],
      [[2, events.where(state: %w(rejecting rejected), event_type: type).count]],
      [[3, events.where(state: %w(withdrawn canceled), event_type: type).count]]
    ]
  end

  def event_duration_sum(events)
    durations = events.accepted.map { |e| e.time_slots * timeslot_duration }
    duration_to_time durations.sum
  end

  def language_breakdown(accepted_only = false)
    result = []
    if accepted_only
      base_relation = events.accepted
    else
      base_relation = events
    end
    languages.each do |language|
      result << { label: language.code, data: base_relation.where(language: language.code).count }
    end
    result << { label: 'unknown', 'data' => base_relation.where(language: '').count }
    result
  end

  def gender_breakdown(accepted_only = false)
    result = []
    ep = Person.joins(events: :conference)
               .where("conferences.id": id)
               .where("event_people.event_role": %w(speaker moderator))
               .where("events.public": true)

    ep = ep.where("events.state": %w(accepting confirmed scheduled)) if accepted_only

    ep.group(:gender).count.each do |k, v|
      k = 'unknown' if k.nil?
      result << { label: k, data: v }
    end

    result
  end

  private

  def duration_to_time(duration_in_minutes)
    '%02d:%02d' % [ duration_in_minutes / 60, duration_in_minutes % 60 ]
  end
end
