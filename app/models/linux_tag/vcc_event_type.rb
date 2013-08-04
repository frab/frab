class LinuxTag::VccEventType < VccDatabase

  establish_connection("lt13_development")
  self.table_name = 'type_event'

  has_many :events, class_name: "LinuxTag::VccEvent", foreign_key: "event_type"

end

