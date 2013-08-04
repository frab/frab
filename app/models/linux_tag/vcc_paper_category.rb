class LinuxTag::VccPaperCategory < VccDatabase

  establish_connection("lt13_development")
  self.table_name = 'category'

  has_many :papers, class_name: "LinuxTag::VccPaper", foreign_key: "category"

end

