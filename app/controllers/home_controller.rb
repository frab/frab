class HomeController < ApplicationController
  layout 'home'

  def index
    @past_conferences = Conference.past
    @future_conferences = Conference.future
  end

  def show
    if @conference.call_for_participation.blank?
      render 'not_existing'
    elsif @conference.call_for_participation.in_the_future?
      render 'open_soon'
    end
  end
end
