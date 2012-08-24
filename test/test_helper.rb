ENV["RAILS_ENV"] = "test"
require File.expand_path('../dummy/config/environment', __FILE__)
require 'rails/test_help'

require "factory_girl_rails"

Rails.backtrace_cleaner.remove_silencers!

PaperTrail.enabled = false

# Load support files
# Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

class ActiveSupport::TestCase
  include FactoryGirl::Syntax::Methods

  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  # fixtures :all

  # Add more helper methods to be used by all tests here...

  def login_as(role)
    user = FactoryGirl.create(
      :user, 
      :person => FactoryGirl.create(:person),
      :role => role.to_s
    )
    session[:user_id] = user.id
    user
  end

end
