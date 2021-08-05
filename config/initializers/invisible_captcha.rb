InvisibleCaptcha.setup do |config|
  config.timestamp_threshold = 2
  config.timestamp_enabled   =  !Rails.env.test?
end
