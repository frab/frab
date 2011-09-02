class Settings < Settingslogic
  source "#{Rails.root}/config/settings.yml"
  namespace Rails.env
  load!
end
