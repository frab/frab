class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :trackable, :validatable,
    :confirmable, :lockable

  ROLES = %w(submitter crew admin).freeze
  USER_ROLES = %w(submitter crew).freeze
  EMAIL_REGEXP = /\A[^@]+@([^@\.]+\.)+[^@\.]+\z/

  has_many :conference_users, dependent: :destroy
  has_one :person

  accepts_nested_attributes_for :conference_users, allow_destroy: true

  attr_accessor :remember_me

  after_initialize :setup_default_values

  validates :person, presence: true
  validates :email, presence: true
  validates :email, format: { with: EMAIL_REGEXP }
  validates :email, uniqueness: { case_sensitive: false }
  validate :conference_user_fields_present
  validate :only_one_role_per_conference

  scope :confirmed, -> { where(arel_table[:confirmed_at].not_eq(nil)) }
  scope :all_admins, -> { where(role: 'admin') }

  self.per_page = 10

  def setup_default_values
    self.role ||= 'submitter'
    self.sign_in_count ||= 0
    self.person ||= Person.new(email: email, public_name: email)
  end

  def newer_than?(user)
    updated_at > user.updated_at
  end

  def is_admin?
    self.role == 'admin'
  end

  def is_submitter?
    self.role == 'submitter'
  end

  def is_crew?
    self.role == 'crew'
  end

  def is_orga_of?(conference)
    has_role?(conference, 'orga')
  end

  def is_manager_of?(conference)
    has_role?(conference, %w[orga coordinator])
  end

  def is_crew_of?(conference)
    is_crew? && conference_users.where(conference_id: conference.id).any?
  end

  def has_role?(conference, role)
    conference_users.where(conference: conference, role: role).any?
  end

  def any_crew?(*roles)
    is_crew? && conference_users.where(role: roles).any?
  end

  def manages_conferences
    conference_users.where(role: %w[orga coordinator])
  end

  def organizes_conferences
    conference_users.where(role: 'orga')
  end

  def reviews_conferences
    conference_users.where(role: 'reviewer').map(&:conference)
  end

  def last_conference
    conference_users.map(&:conference).last
  end

  private

  def conference_user_fields_present
    return if conference_users.map { |cu| cu.conference.nil? || cu.role.nil? }.none?
    errors.add(:role, 'Missing fields on conference user.')
  end

  def only_one_role_per_conference
    seen = {}
    conference_users.each { |cu|
      next if cu.conference.nil?
      if seen.key? cu.conference.id
        errors.add(:role, 'User cannot have multiple roles in one conference')
        return
      end
      seen[cu.conference.id] = 1
    }
  end
end
