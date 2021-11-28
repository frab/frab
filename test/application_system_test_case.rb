require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  include CapybaraHelper
  driven_by :selenium, using: :headless_chrome, screen_size: [1400, 1400]

  DatabaseCleaner.strategy = :truncation

  def setup
    DatabaseCleaner.start
    I18n.locale = I18n.default_locale
  end

  def teardown
    DatabaseCleaner.clean
  end
end
