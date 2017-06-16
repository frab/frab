class BaseCrewController < ApplicationController
  before_action :authenticate_user!
  before_action :not_submitter!
  before_action :any_crew!
  after_action :verify_authorized

  private

  def any_crew!
    authorize Conference, :index?
  end
end
