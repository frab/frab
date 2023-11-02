require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  include CapybaraHelper
  driven_by :selenium, using: :headless_chrome, screen_size: [1400, 1400]

  def setup
    I18n.locale = I18n.default_locale

    Webdrivers::Chromedriver.required_version = '114.0.5735.90'
  end
end
