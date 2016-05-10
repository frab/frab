class ConferenceUser < ActiveRecord::Base
  ROLES = %w(reviewer coordinator orga)

  belongs_to :conference
  belongs_to :user

  validates :conference, :user, :role, presence: true
  validate :user_role_is_crew
  validate :role_is_valid

  private

  def role_is_valid
    self.errors.add(:role, 'You need to select a valid role') unless ROLES.include? self.role
  end

  def user_role_is_crew
    self.errors.add(:role, 'User role is not crew') unless self.user and self.user.is_crew?
  end
end
