class HomeController < ApplicationController
  layout 'home'

  def index
    @past_conferences = Conference.past.includes(:call_for_participation)
    @future_conferences = Conference.future.includes(:call_for_participation)
  end
end
