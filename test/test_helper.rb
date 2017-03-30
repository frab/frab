ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'minitest/pride'
require 'database_cleaner'
require 'sucker_punch/testing/inline'

class ActiveSupport::TestCase
  ActiveRecord::Migration.check_pending!
  include FactoryGirl::Syntax::Methods

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  # fixtures :all

  # Add more helper methods to be used by all tests here...

  DatabaseCleaner.strategy = :truncation

  def login_as(role)
    user = FactoryGirl.create(:user, role: role.to_s)
    sign_in(user)
    user
  end

  def sign_in(user)
    post '/session', params: { user: { email: user.email, password: user.password } }
  end

  def setup
    DatabaseCleaner.start
    I18n.locale = I18n.default_locale
  end

  def teardown
    DatabaseCleaner.clean
  end
end

class ActionController::TestCase
  include Devise::Test::ControllerHelpers
end

class ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
end
