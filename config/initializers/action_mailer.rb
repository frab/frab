ActionMailer::Base.default_url_options = {
  host: ENV.fetch('FRAB_HOST'),
  protocol: ENV.fetch('FRAB_PROTOCOL')
}
if ENV['SMTP_ADDRESS']
  %w(ADDRESS PORT DOMAIN USER_NAME PASSWORD).each do |setting|
    next unless ENV["SMTP_#{setting}"].present?
    ActionMailer::Base.smtp_settings[setting.downcase.to_sym] = ENV["SMTP_#{setting}"]
  end
end
if ENV['SMTP_NOTLS'].present?
  ActionMailer::Base.smtp_settings.merge!(
    enable_starttls_auto: false,
    ssl: false,
    tls: false
  )
end
