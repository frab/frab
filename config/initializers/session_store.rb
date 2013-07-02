# Be sure to restart your server when you modify this file.

Frab::Application.config.session_store :active_record_store, key: '_frab_session'

# Example for a cookie store, with secure flag set for SSL hosting in production mode
#
# Frab::Application.config.session_store :cookie_store,
#                                       key: '_frab_session',
#                                       secure: Rails.env == 'production',
#                                       httponly: true,
#                                       expire_after: 60.minutes 
