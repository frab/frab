class PossibleStartTimes
  def initialize(event)
    @event = event
    @conference = event.conference
  end

  def all
    possible = {}

    # Retrieve a list of persons that are presenting this event,
    # and filter out those who don't have any availabilities configured.

    @conference.days.each do |day|
      availabilities = Availability.where(person: available_presenters, day: day)

      times = day.start_times_map do |time, pretty|
        # People with no availability at all are not present in available_presenters.
        # Hence, if the number of availability records for this day is less
        # than the number of presenters in available_presenters, we know that at least
        # one of them is not available.
        if presenters_available_at(availabilities, time).all?
          [pretty, time.to_s]
        elsif @event.start_time == time
          # Special case: if the event is already scheduled, offer that start time
          # in the list as well, but add a warning, so that records are not accidentally
          # modified through HTML forms.

          [pretty + ' (not all presenters available!)', time.to_s]
        end
      end

      times.compact!
      possible[day.to_s] = times if times.any?
    end

    possible
  end

  private

  def presenters_available_at(availabilities, time)
    if availabilities.length == available_presenters.length
      availabilities.map { |a| a.within_range?(time) }
    else
      [false]
    end
  end

  def available_presenters
    @available_presenters ||= @event.event_people.presenter.group(:person_id, :id)
      .select { |ep| ep.person.availabilities.any? }
      .map(&:person_id)
  end
end
