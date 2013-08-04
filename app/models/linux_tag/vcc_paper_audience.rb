class LinuxTag::VccPaperAudience < VccDatabase

  establish_connection("lt13_development")
  self.table_name = 'audience'

  has_many :papers, class_name: "LinuxTag::VccPaper", foreign_key: "audience"

end

