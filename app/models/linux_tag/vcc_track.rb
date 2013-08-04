class LinuxTag::VccTrack < VccDatabase

  establish_connection("lt13_development")
  self.table_name = 'type_track'

  has_and_belongs_to_many :papers, class_name: "LinuxTag::VccPaper", 
    association_foreign_key: "paper", join_table: "track", foreign_key: "track" 
  has_and_belongs_to_many :sessionchairs, class_name: "LinuxTag::VccPerson", 
    association_foreign_key: "person", join_table: "sessionchair", foreign_key: "track" 

end

