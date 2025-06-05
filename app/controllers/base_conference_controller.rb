class BaseConferenceController < ApplicationController
  layout 'conference'
  before_action :authenticate_user!
  # before_action :not_submitter!
  before_action :not_submitter!, except: [:edit_people, :invite_people, :lookup]
  after_action :verify_authorized
end
