class ConferenceScrubber
  include RakeLogger

  DUMMY_MAIL = "root@localhost.localdomain"

  def initialize(conference, dry_run = false)
    @conference = conference
    @dry_run = dry_run
    @current_conferences = last_years_conferences
    PaperTrail.enabled = false
  end

  def scrub!
    log "dry run, won't change anything!" if @dry_run
    ActiveRecord::Base.transaction do
      scrub_people
      scrub_event_ratings
    end
  end

  private

  def scrub_people
    Person.involved_in(@conference).each { |person|
      unless still_active(person)
        log "scrubbing #{person.public_name} <#{person.email}>"
        scrub_person(person)
      end
    }
  end

  def last_years_conferences
    Conference.all.select { |c| c.first_day.date.since(1.year) > Time.now }
  end

  def still_active(person)
    @current_conferences.each { |c|
      return true if person.involved_in?(c)
    }
    false
  end

  def scrub_person(person)
    # get a writable record
    person = Person.find person.id

    unless person.email_public or person.include_in_mailings
      person.email = DUMMY_MAIL
    end
    person.phone_numbers.destroy_all unless @dry_run
    person.im_accounts.destroy_all unless @dry_run
    person.note = nil

    unless person.active_in_any_conference?
      log "scrubbing description of #{person.public_name}"
      person.abstract = nil
      person.description = nil
      person.avatar.destroy unless @dry_run
      person.links.destroy_all unless @dry_run
    end
    person.save! unless @dry_run
  end

  def scrub_event_ratings
    return if @dry_run
    log "scrubbing conference ratings of #{@conference.acronym}"
    # keeps events average rating for performance reasons
    EventRating.skip_callback(:save, :after, :update_average)
    EventRating.joins(:event).where(Event.arel_table[:conference_id].eq(@conference.id)).destroy_all
  end
end
