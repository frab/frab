class ConferenceUser < ActiveRecord::Base
  ROLES = %w{reviewer coordinator orga}

  belongs_to :conference
  belongs_to :user
  attr_accessible :role, :conference_id

  validates :conference, presence: true
  validates :user, presence: true
  validates_presence_of :role
  validate :user_role_is_crew
  validate :role_is_valid

  private
  
  def role_is_valid
    self.errors.add(:role, "You need to select a valid role") unless ROLES.include? self.role
  end

  def user_role_is_crew
    self.errors.add(:role, "User role is not crew") if self.user.role != 'crew'
  end

end
