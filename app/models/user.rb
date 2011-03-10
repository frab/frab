class User < ActiveRecord::Base

  has_one :person
  
  # Include default devise modules. Others available are:
  # :token_authenticatable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me

  def self.check_pentabarf_credentials(email, password)
    user = User.find_by_email(email)
    return unless user and user.pentabarf_password and user.pentabarf_salt
    salt = [user.pentabarf_salt.to_i( 16 )].pack("Q").reverse
    
    if Digest::MD5.hexdigest( salt + password ) == user.pentabarf_password
      user.update_attributes!(:password => password, :password_confirmation => password)
    end
  end

end
