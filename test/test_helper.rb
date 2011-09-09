ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActionController::TestCase
  include Devise::TestHelpers
end

class ActiveSupport::TestCase

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
    case role
    when :admin
      sign_in user 
    when :submitter
      sign_in :cfp_user, user
    end
    user
  end

end
