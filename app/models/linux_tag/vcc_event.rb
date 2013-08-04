#
# Important: as the word 'type' is a reserved word in Ruby one
# has to
#
#  ALTER TABLE event RENAME COLUMN type TO event_type;
#
# on the vCC database to make this model work.
#
class LinuxTag::VccEvent < VccDatabase

  establish_connection("lt13_development")
  self.table_name = 'event'

  belongs_to :presentation, class_name: "LinuxTag::VccPaper",     foreign_key: "presentation"
  belongs_to :event_type,   class_name: "LinuxTag::VccEventType", foreign_key: "event_type"
  belongs_to :panel,        class_name: "LinuxTag::VccPanel",     foreign_key: "panel"
  belongs_to :room,         class_name: "LinuxTag::VccRoom",      foreign_key: "room"

  def frab_event(conference)
    e = Event.new(
      title:                 presentation.title,
      language:              presentation.language,
      abstract:              presentation.abstract,
      time_slots:            Time.parse(dur).strftime('%M').to_i / conference.timeslot_duration,
      start_time:            DateTime.new(date.year, date.month, date.day, starttime.hour, starttime.min, 0, '+2'),
      conference:            conference,
      room:                  Room.find_by_name('%s (%s)' % [room.comment, room.name]),
      state:                 'confirmed',
      public:                true,
    )
    presentation.authorships.each do |as| 
      e.event_people << EventPerson.new(
        person: Person.find_by_public_name( as.author.username ),
        event_role: "speaker"
      )
      e.event_people << EventPerson.new(
        person: Person.find_by_public_name( as.author.username ),
        event_role: "submitter"
      ) if as.status == 1
    end
    return e
    #@user.call_for_papers = @conference.call_for_papers
  end

end

