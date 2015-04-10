ActionMailer::Base.default_url_options = {
  host: ENV.fetch("FRAB_HOST"),
  protocol: ENV.fetch("FRAB_PROTOCOL")
}
if ENV["SMTP_ADDRESS"]
  smtp_settings = Hash.new
  %w(ADDRESS PORT DOMAIN USER_NAME PASSWORD).each do |setting|
    if ENV["SMTP_#{setting}"].present?
      smtp_settings.merge!({setting.downcase => ENV["SMTP_#{setting}"]})
    end
  end
  ActionMailer::Base.smtp_settings = smtp_settings
end
