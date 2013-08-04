class LinuxTag::VccAuthorshipStatus < VccDatabase

  establish_connection("lt13_development")
  self.table_name = 'status_authorship'

  has_many :authorships, class_name: "LinuxTag::VccAuthorship", foreign_key: "status"

end

