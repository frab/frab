class Ticket < ApplicationRecord
  belongs_to :object, polymorphic: true

  def event
    object if object_type == 'Event'
  end

  def person
    object if object_type == 'Person'
  end
end
