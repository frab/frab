class Cfp::WelcomeController < ApplicationController
  layout 'home'

  def show
    if @conference.call_for_participation.blank?
      render 'not_existing'
    elsif @conference.call_for_participation.in_the_future?
      render 'open_soon'
    end
  end
end
