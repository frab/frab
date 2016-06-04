class User < ActiveRecord::Base
  include UniqueToken

  ROLES = %w(submitter crew admin)
  USER_ROLES = %w(submitter crew)
  EMAIL_REGEXP = /\A[^@]+@([^@\.]+\.)+[^@\.]+\z/

  has_many :conference_users, dependent: :destroy
  has_one :person

  accepts_nested_attributes_for :conference_users, allow_destroy: true

  has_secure_password

  attr_accessor :remember_me

  after_initialize :check_default_values
  before_create :generate_confirmation_token, unless: :confirmed_at

  validates_presence_of :person
  validates_presence_of :email
  validates_format_of :email, with: EMAIL_REGEXP
  validates_uniqueness_of :email, case_sensitive: false
  validates_length_of :password, minimum: 6, allow_nil: true
  validate :conference_user_fields_present
  validate :only_one_role_per_conference

  scope :confirmed, -> { where(arel_table[:confirmed_at].not_eq(nil)) }

  def check_default_values
    self.role ||= 'submitter'
    self.sign_in_count ||= 0
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

  def is_crew_of?(conference)
    self.is_crew? and self.conference_users.select { |cu| cu.conference_id == conference.id }.any?
  end

  def self.check_pentabarf_credentials(email, password)
    user = User.find_by_email(email)
    return unless user and user.pentabarf_password and user.pentabarf_salt
    salt = [user.pentabarf_salt.to_i(16)].pack('Q').reverse

    if Digest::MD5.hexdigest(salt + password) == user.pentabarf_password
      user.password = password
      user.password_confirmation = password
      user.pentabarf_password = nil
      user.pentabarf_salt = nil
      user.save
    end
  end

  def self.confirm_by_token(token)
    user = self.find_by_confirmation_token(token)
    if user
      user.confirmed_at = Time.now
      user.confirmation_token = nil
      user.save
    end
    user
  end

  def send_confirmation_instructions(conference = nil)
    return false if confirmed_at
    generate_confirmation_token! unless self.confirmation_token
    UserMailer.confirmation_instructions(self, conference).deliver_now
  end

  # update users call for papers and sends mail
  def send_password_reset_instructions(conference)
    generate_password_reset_token!
    UserMailer.password_reset_instructions(self, conference).deliver_now
  end

  def reset_password(params)
    self.password = params[:password]
    self.password_confirmation = params[:password_confirmation]
    self.reset_password_token = nil
    save
  end

  def skip_confirmation!
    self.confirmed_at = Time.now
  end

  def authenticate(password_entered)
    if super(password_entered) or (ENV['DEVISE_PEPPER'] and super(password_entered + ENV['DEVISE_PEPPER']))
      self
    else
      false
    end
  end

  def record_login!
    update_attributes(last_sign_in_at: Time.now, sign_in_count: sign_in_count + 1)
  end

  private

  def conference_user_fields_present
    return if self.conference_users.map { |cu| cu.conference.nil? || cu.role.nil? }.none?
    self.errors.add(:role, 'Missing fields on conference user.')
  end

  def only_one_role_per_conference
    seen = {}
    self.conference_users.each { |cu|
      next if cu.conference.nil?
      if seen.key? cu.conference.id
        self.errors.add(:role, 'User cannot have multiple roles in one conference')
        return
      end
      seen[cu.conference.id] = 1
    }
  end

  def generate_confirmation_token
    generate_token_for(:confirmation_token)
  end

  def generate_confirmation_token!
    generate_confirmation_token
    save
  end

  def generate_password_reset_token!
    generate_token_for(:reset_password_token)
    save
  end
end
