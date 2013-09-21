class ConferenceUser < ActiveRecord::Base
  ROLES = %w{reviewer coordinator orga}

  belongs_to :user
  belongs_to :conference
  attr_accessible :role

  validates_presence_of :role
  validate :role_is_valid
  
  def role_is_valid
    ROLES.include? self.role
  end
end
