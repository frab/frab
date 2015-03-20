ActionMailer::Base.default_url_options = {
  host: ENV.fetch('FRAB_HOST'),
  protocol: ENV.fetch('FRAB_PROTOCOL')
}
if ENV["SMTP_ADDRESS"]
  smtp_settings = {}
  %w(ADDRESS PORT DOMAIN USER_NAME PASSWORD).each do |setting|
    next unless ENV["SMTP_#{setting}"]
    smtp_settings[setting.downcase] = ENV["SMTP_#{setting}"]
  end
  ActionMailer::Base.smtp_settings = smtp_settings
end
