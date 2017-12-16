class ConferenceUser < ApplicationRecord
  ROLES = %w(reviewer coordinator orga).freeze

  belongs_to :conference
  belongs_to :user
  has_one :person, through: :user

  validates :conference, :user, :role, presence: true
  validate :user_role_is_crew
  validate :role_is_valid

  self.per_page = 20

  private

  def role_is_valid
    errors.add(:role, I18n.t('errors.messages.invalid_role')) unless ROLES.include? role
  end

  def user_role_is_crew
    errors.add(:role, I18n.t('users_module.role_not_crew')) unless user and user.is_crew?
  end
end
