class Cfp::WelcomeController < ApplicationController
  layout 'cfp'
  def show
    if current_user and session[:conference_acronym]
      if @conference && policy(@conference).manage?
        redirect_to conference_path(conference_acronym: session[:conference_acronym])
      else
        if current_user.person.public_name == current_user.email
          redirect_to edit_cfp_person_path(conference_acronym: session[:conference_acronym])
        else
          redirect_to cfp_person_path(conference_acronym: session[:conference_acronym])
        end
      end
    end

    if @conference.call_for_participation.blank?
      render 'not_existing'
    elsif @conference.call_for_participation.in_the_future?
      render 'open_soon'
    end
  end
end
