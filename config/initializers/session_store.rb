# Be sure to restart your server when you modify this file.

# Example for a cookie store, with secure flag set for SSL hosting in production mode
#

if ENV.fetch('FRAB_USE_AR_STORE', 'false') == 'true'
  Rails.application.config.session_store :active_record_store,
    key: ENV.fetch('FRAB_SESSION_STORE_KEY', '_frab_session'),
    secure: true

else
  Rails.application.config.session_store :cookie_store,
    key: ENV.fetch('FRAB_SESSION_STORE_KEY', '_frab_session'),
    secure: Rails.env == 'production' && ENV['FRAB_PROTOCOL'] == 'https',
    httponly: true,
    expire_after: 60.minutes
end
