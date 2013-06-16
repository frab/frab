class User < ActiveRecord::Base
  include UniqueToken

  ROLES = ["submitter", "reviewer", "coordinator", "orga", "admin"]
  EMAIL_REGEXP = /\A[^@]+@([^@\.]+\.)+[^@\.]+\z/

  belongs_to :call_for_participation
  has_one :person
 
  has_secure_password
  
  attr_accessor :remember_me

  attr_accessible :email, :password, :password_confirmation, :remember_me, :call_for_participation_id

  after_initialize :check_default_values

  def check_default_values
    self.role ||= 'submitter'
    self.sign_in_count ||= 0
  end

  def is_submitter
    return true if self.role == "submitter"
    false
  end

  scope :confirmed, where(arel_table[:confirmed_at].not_eq(nil))
  validates_presence_of :person
  validates_presence_of :email
  validates_format_of :email, with: EMAIL_REGEXP
  validates_uniqueness_of :email
  validates_length_of :password, minimum: 6, allow_nil: true

  before_create :generate_confirmation_token, unless: :confirmed_at
  after_create :send_confirmation_instructions, unless: :confirmed_at

  def self.check_pentabarf_credentials(email, password)
    user = User.find_by_email(email)
    return unless user and user.pentabarf_password and user.pentabarf_salt
    salt = [user.pentabarf_salt.to_i( 16 )].pack("Q").reverse
    
    if Digest::MD5.hexdigest( salt + password ) == user.pentabarf_password
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

  def send_confirmation_instructions
    return false if confirmed_at
    generate_confirmation_token! unless self.confirmation_token
    UserMailer.confirmation_instructions(self).deliver
  end

  def send_password_reset_instructions(call_for_participation = nil)
    if call_for_participation
      self.call_for_participation = call_for_participation
    end
    generate_password_reset_token!
    UserMailer.password_reset_instructions(self).deliver
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
    if super(password_entered) or (Settings['devise_pepper'] and super(password_entered + Settings['devise_pepper']))
      self
    else
      false
    end
  end

  def record_login!
    self.last_sign_in_at = Time.now
    self.sign_in_count += 1
    save(validate: false)
  end

  private

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
