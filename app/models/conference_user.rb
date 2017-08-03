class ConferenceUser < ApplicationRecord
  ROLES = %w(reviewer coordinator orga).freeze

  belongs_to :conference
  belongs_to :user

  validates :conference, :user, :role, presence: true
  validate :user_role_is_crew
  validate :role_is_valid

  self.per_page = 20

  private

  def role_is_valid
    errors.add(:role, 'You need to select a valid role') unless ROLES.include? role
  end

  def user_role_is_crew
    errors.add(:role, 'User role is not crew') unless user and user.is_crew?
  end
end
