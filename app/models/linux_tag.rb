class VccDatabase < ActiveRecord::Base
  
  self.abstract_class = true
  establish_connection("lt13_development")
   
end

class LinuxTag < ActiveRecord::Base

end

# credit to http://stackoverflow.com/questions/14711505/
Dir["#{Rails.root}/app/models/linux_tag/*.rb"].each do |file|
  require_dependency file
end

