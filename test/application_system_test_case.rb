require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  include CapybaraHelper

  # Configure Chrome options for more stable testing
  driven_by :selenium, using: :headless_chrome, screen_size: [2560, 1440] do |driver_option|
    driver_option.add_argument('--disable-dev-shm-usage')
    driver_option.add_argument('--disable-extensions')
    driver_option.add_argument('--disable-gpu')
    driver_option.add_argument('--disable-web-security')
    driver_option.add_argument('--no-sandbox')
    # Reduce animation timing for faster, more predictable tests
    driver_option.add_argument('--disable-background-timer-throttling')
    driver_option.add_argument('--disable-renderer-backgrounding')
  end

  def setup
    I18n.locale = I18n.default_locale
    Capybara.server = :puma, { Silent: true, Threads: '0:23' }

    # Increase default wait time for more stable tests
    Capybara.default_max_wait_time = 10
  end
end


module Selenium
  module WebDriver
    module Error
      class UnknownError
        alias_method :old_initialize, :initialize
        def initialize(msg = nil)
          if msg&.include?("Node with given id does not belong to the document")
            raise StaleElementReferenceError, msg
          end

          old_initialize(msg)
        end
      end
    end
  end
end
