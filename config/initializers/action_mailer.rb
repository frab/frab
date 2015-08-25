ActionMailer::Base.default_url_options = {
  host: ENV.fetch('FRAB_HOST'),
  protocol: ENV.fetch('FRAB_PROTOCOL')
}
if ENV["SMTP_ADDRESS"]
  %w(ADDRESS PORT DOMAIN USER_NAME PASSWORD).each do |setting|
    next unless ENV["SMTP_#{setting}"]
    ActionMailer::Base.smtp_settings[setting.downcase.to_sym] = ENV["SMTP_#{setting}"]
  end
end
