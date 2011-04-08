class User < ActiveRecord::Base

  ROLES = ["submitter", "admin"]

  belongs_to :call_for_papers
  has_one :person
  
  # Include default devise modules. Others available are:
  # :token_authenticatable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :call_for_papers_id

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

end
