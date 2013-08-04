class LinuxTag::VccPaper < VccDatabase

  establish_connection("lt13_development")
  self.table_name = 'paper'

  belongs_to :audience, class_name: "LinuxTag::VccPaperAudience", foreign_key: "audience"
  belongs_to :category, class_name: "LinuxTag::VccPaperCategory", foreign_key: "category"
  belongs_to :status,   class_name: "LinuxTag::VccPaperStatus",   foreign_key: "status"

  has_many :authorships, class_name: "LinuxTag::VccAuthorship",   foreign_key: "paper"
  has_many :authors,     through: :authorships
  has_many :events,      class_name: "LinuxTag::VccEvent",        foreign_key: "presentation"
  has_many :links,       class_name: "LinuxTag::VccPaperLink",    foreign_key: "paper"

  has_and_belongs_to_many :licenses, class_name: "LinuxTag::VccPaperLicense", 
    association_foreign_key: "license", join_table: "licenses", foreign_key: "paper"
  has_and_belongs_to_many :tracks, class_name: "LinuxTag::VccTrack", 
    association_foreign_key: "track", join_table: "track", foreign_key: "paper"

  def basic_event(conference)
    e = Event.new(
      conference:            conference,
      title:                 title,
      language:              language,
      abstract:              abstract_short,
      description:           abstract,
      time_slots:            1
    )
    authorships.each do |vccas|
      person = Person.find_by_public_name( vccas.author.username )
      next if person.nil?
      e.event_people << EventPerson.new(
        person: person,
        event_role: "speaker"
      )
      e.event_people << EventPerson.new(
        person: person,
        event_role: "submitter"
      ) if vccas.status.try(:id) == 1
    end
    return e
  end

  def frab_event(conference)
    # build the basic event with its authors
    return if id == 0 # paper 0 is special
    if ( events.empty? )  # unaccepted paper
      e = basic_event(conference)
      e.state = "review"
      e.public = false
      e.save!
    else 
      events.each do |vccev|
        e = basic_event(conference)
        e.state = "confirmed"
        e.time_slots = Time.parse(vccev.dur).strftime('%M').to_i / conference.timeslot_duration
        e.start_time = DateTime.new(vccev.date.year, vccev.date.month, vccev.date.day, vccev.starttime.hour, vccev.starttime.min, 0, '+2')
        e.room = Room.find_by_name('%s (%s)' % [vccev.room.comment, vccev.room.name])
        e.save!
      end 
    end

    return 
    #@user.call_for_papers = @conference.call_for_papers
  end


end

