ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'

# Suppress the warning that SQLite3 issues when open writable connections are carried across fork()
if ActiveRecord::Base.connection.adapter_name == 'SQLite'
  SQLite3::ForkSafety.suppress_warnings!
end

require 'minitest/pride'
require 'minitest/spec'
require 'sucker_punch/testing/inline'

Dir[Rails.root.join('test/support/**/*.rb')].each { |f| require f }

# Unit tests in test/unit
class ActiveSupport::TestCase
  ActiveRecord::Migration.check_all_pending!
  include FactoryBot::Syntax::Methods

  # Configure parallel testing with SQLite fork safety
  parallelize(workers: :number_of_processors)

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  # fixtures :all

  # Add more helper methods to be used by all tests here...

  def setup
    I18n.locale = I18n.default_locale
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
