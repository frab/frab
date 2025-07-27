require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  include CapybaraHelper
  driven_by :selenium, using: :headless_chrome, screen_size: [1400, 1400]

  def setup
    I18n.locale = I18n.default_locale
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
