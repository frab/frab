class BaseConferenceController < ApplicationController
  layout 'conference'
  before_action :authenticate_user!
  before_action :not_submitter!
  after_action :verify_authorized
end
