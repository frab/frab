ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'

require 'minitest/pride'
require 'minitest/spec'
require 'database_cleaner/active_record'
require 'sucker_punch/testing/inline'

Dir[Rails.root.join('test/support/**/*.rb')].each { |f| require f }

# Unit tests in test/unit
class ActiveSupport::TestCase
  ActiveRecord::Migration.check_pending!
  include FactoryBot::Syntax::Methods

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  # fixtures :all

  # Add more helper methods to be used by all tests here...
  DatabaseCleaner.strategy = :truncation

  def setup
    DatabaseCleaner.start
    I18n.locale = I18n.default_locale
  end

  def teardown
    DatabaseCleaner.clean
  end
end

# Controller tests in test/controllers
class ActionController::TestCase
  include Devise::Test::ControllerHelpers

  def login_as(role)
    user = FactoryBot.create(:user, role: role.to_s)
    sign_in(user)
    user
  end

  def log_out
    sign_out(:user)
  end
end

# Integration tests in test/integration
class ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
end

# Integration tests in test/integration
class PunditControllerTest < ActionDispatch::IntegrationTest
  include CrewRolesHelper
end
