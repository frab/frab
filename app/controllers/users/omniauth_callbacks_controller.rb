class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController

  protect_from_forgery :except => [:failure, :ldap]

  def all
    @user = User.from_omniauth(request.env['omniauth.auth'])
   
    if @user.persisted?
      sign_in_and_redirect @user, :event => :authentication, :method => :post
      set_flash_message(:notice, :success, :kind => t(action_name, scope: 'devise.links')) if is_navigational_format?
    else
      session['devise.'+action_name+'_data'] = request.env['omniauth.auth'].except(:extra) # Removing extra as it can overflow some session stores
      redirect_to root_path, alert: @user.errors.full_messages.join("\n") 
    end
  end
  
  alias :ldap :all

  alias :google_oauth2 :all

  alias :openid_connect :all

  def failure
    set_flash_message(:alert, :unknown_failure) if is_navigational_format?
    redirect_to root_path
  end
end
