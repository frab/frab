class Ticket < ActiveRecord::Base
  belongs_to :object, polymorphic: true

  def event
    self.object if self.object_type == "Event"
  end

  def person
    self.object if self.object_type == "Person"
  end

end
