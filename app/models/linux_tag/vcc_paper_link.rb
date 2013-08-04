class LinuxTag::VccPaperLink < VccDatabase

  establish_connection("lt13_development")
  self.table_name = 'link'

  belongs_to :paper, class_name: "LinuxTag::VccPaper", foreign_key: "paper"

end

