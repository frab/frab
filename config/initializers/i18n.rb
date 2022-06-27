if ENV['FRAB_DEFAULT_LOCALE'].present? && !Rails.env.test?
  I18n.default_locale = ENV['FRAB_DEFAULT_LOCALE']
end
