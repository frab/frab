class LinuxTag::VccAuthorship < VccDatabase

  establish_connection("lt13_development")
  self.table_name = 'authorship'

  belongs_to :author, class_name: "LinuxTag::VccPerson", foreign_key: "author"
  belongs_to :paper, class_name: "LinuxTag::VccPaper", foreign_key: "paper"
  belongs_to :status, class_name: "LinuxTag::VccAuthorshipStatus", foreign_key: "status"

end

