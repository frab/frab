class LinuxTag::VccPanel < VccDatabase

  establish_connection("lt13_development")
  self.table_name = 'panel'

  has_many :events, class_name: "LinuxTag::VccEvent", foreign_key: "panel"

end

