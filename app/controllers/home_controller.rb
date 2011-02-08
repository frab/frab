class HomeController < ApplicationController

  before_filter :authenticate_user! 

  def index
    if Conference.count == 0
      redirect_to new_conference_path
    end
  end
end
