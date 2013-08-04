class LinuxTag::VccPerson < VccDatabase

  establish_connection("lt13_development")
  self.table_name = 'person'

  has_many :authorships, class_name: "LinuxTag::VccAuthorship", foreign_key: "author"
  has_many :papers, through: :authorships


  def frab_person_attributes
    {
      first_name:            firstname, 
      last_name:             lastname, 
      public_name:           username,
      user:                  User.new( email: email ),
      email:                 email, 
      abstract:              bio, 
    }
    #@user.call_for_papers = @conference.call_for_papers
  end
  
end

