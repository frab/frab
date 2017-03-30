class HomeController < ApplicationController
  layout 'home'

  def index
    @past_conferences = Conference.past
    @future_conferences = Conference.future
  end
end
