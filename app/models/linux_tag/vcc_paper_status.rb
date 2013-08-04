class LinuxTag::VccPaperStatus < VccDatabase

  establish_connection("lt13_development")
  self.table_name = 'status_paper'

  has_many :papers, class_name: "LinuxTag::VccPaper", foreign_key: "status"
end

