class SendBulkMailJob
  include SuckerPunch::Job

  def perform(template, send_filter)
    persons = Person
                .joins(events: :conference)
                .where(:'conferences.id' => template.conference.id)

    case send_filter
      when "all_speakers_in_confirmed_events"
        persons = persons
                    .where(:'events.state' => 'confirmed')
                    .where(:'event_people.event_role' => 'speaker')

      when "all_speakers_in_unconfirmed_events"
        persons = persons
                    .where(:'events.state' => 'unconfirmed')
                    .where(:'event_people.event_role' => 'speaker')
    end

    persons = persons.group(:'people.id')

    persons.each do |p|
      UserMailer.bulk_mail(p, template).deliver_now
      Rails.logger.info "Mail template #{template.name} delivered to #{p.first_name} #{p.last_name} (#{p.email})"
    end
  end

end

